import { Component, computed, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { AuthService } from '../../../core/services/auth.service';
import { SupabaseClientService } from '../../../core/services/supabase-client.service';

interface Pipeline { id: string; name: string; }
interface Stage { id: string; pipeline_id: string; name: string; position: number; }
interface Task { id: string; title: string; description: string | null; priority: string; due_date: string | null; pipeline_id: string; stage_id: string; pipeline: { name: string } | null; stage: { name: string } | null; }

@Component({ selector: 'app-tasks', standalone: true, imports: [DatePipe, ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatSelectModule], templateUrl: './tasks.component.html', styleUrl: './tasks.component.scss' })
export class TasksComponent {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly supabase = inject(SupabaseClientService).client;
  readonly tasks = signal<Task[]>([]);
  readonly pipelines = signal<Pipeline[]>([]);
  readonly stages = signal<Stage[]>([]);
  readonly loading = signal(true);
  readonly saving = signal(false);
  readonly errorMessage = signal<string | null>(null);
  readonly selectedStage = signal('all');
  readonly visibleTasks = computed(() => this.selectedStage() === 'all' ? this.tasks() : this.tasks().filter((task) => task.stage_id === this.selectedStage()));
  readonly form = this.fb.nonNullable.group({ title: ['', [Validators.required, Validators.maxLength(300)]], description: [''], pipeline_id: ['', Validators.required], stage_id: ['', Validators.required], priority: ['medium', Validators.required], due_date: [''] });

  constructor() { void this.loadData(); }

  stagesFor(pipelineId: string): Stage[] { return this.stages().filter((stage) => stage.pipeline_id === pipelineId); }

  pipelineChanged(pipelineId: string): void { this.form.patchValue({ pipeline_id: pipelineId, stage_id: this.stagesFor(pipelineId)[0]?.id ?? '' }); }

  async loadData(): Promise<void> {
    const organizationId = this.auth.profile()?.organization_id;
    if (!organizationId) { this.loading.set(false); return; }
    const [tasks, pipelines, stages] = await Promise.all([
      this.supabase.from('tasks').select('id, title, description, priority, due_date, pipeline_id, stage_id, pipeline:pipelines(name), stage:pipeline_stages(name)').eq('organization_id', organizationId).is('archived_at', null).order('due_date', { ascending: true }),
      this.supabase.from('pipelines').select('id, name').eq('organization_id', organizationId).is('archived_at', null).order('name'),
      this.supabase.from('pipeline_stages').select('id, pipeline_id, name, position').eq('organization_id', organizationId).is('archived_at', null).order('position'),
    ]);
    this.loading.set(false);
    const error = tasks.error || pipelines.error || stages.error;
    if (error) { this.errorMessage.set(error.message); return; }
    this.tasks.set((tasks.data ?? []) as unknown as Task[]); this.pipelines.set((pipelines.data ?? []) as Pipeline[]); this.stages.set((stages.data ?? []) as Stage[]);
    const firstPipeline = this.pipelines()[0]; if (firstPipeline) this.pipelineChanged(firstPipeline.id);
  }

  async addTask(): Promise<void> {
    const profile = this.auth.profile();
    if (!profile || this.form.invalid || this.saving()) { this.form.markAllAsTouched(); return; }
    this.saving.set(true); this.errorMessage.set(null);
    const value = this.form.getRawValue();
    const { error } = await this.supabase.from('tasks').insert({ organization_id: profile.organization_id, created_by: profile.id, ...value, due_date: value.due_date || null });
    this.saving.set(false); if (error) { this.errorMessage.set(error.message); return; }
    this.form.patchValue({ title: '', description: '', due_date: '' }); await this.loadData();
  }
}