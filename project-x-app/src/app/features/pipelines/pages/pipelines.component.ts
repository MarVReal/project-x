import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { AuthService } from '../../../core/services/auth.service';
import { PermissionService } from '../../../core/services/permission.service';
import { SupabaseClientService } from '../../../core/services/supabase-client.service';

interface Pipeline { id: string; name: string; description: string | null; color: string; }
interface Stage { id: string; pipeline_id: string; name: string; color: string; position: number; is_completed: boolean; }

@Component({ selector: 'app-pipelines', standalone: true, imports: [ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule], templateUrl: './pipelines.component.html', styleUrl: './pipelines.component.scss' })
export class PipelinesComponent {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  readonly permissions = inject(PermissionService);
  private readonly supabase = inject(SupabaseClientService).client;
  readonly pipelines = signal<Pipeline[]>([]);
  readonly stages = signal<Stage[]>([]);
  readonly loading = signal(true);
  readonly saving = signal(false);
  readonly errorMessage = signal<string | null>(null);
  readonly form = this.fb.nonNullable.group({ name: ['', [Validators.required, Validators.maxLength(150)]], description: [''], color: ['#2f6f6d', Validators.required] });

  constructor() { void this.loadPipelines(); }

  async loadPipelines(): Promise<void> {
    const organizationId = this.auth.profile()?.organization_id;
    if (!organizationId) { this.loading.set(false); return; }
    const [pipelines, stages] = await Promise.all([
      this.supabase.from('pipelines').select('id, name, description, color').eq('organization_id', organizationId).is('archived_at', null).order('name'),
      this.supabase.from('pipeline_stages').select('id, pipeline_id, name, color, position, is_completed').eq('organization_id', organizationId).is('archived_at', null).order('position'),
    ]);
    this.loading.set(false);
    if (pipelines.error || stages.error) { this.errorMessage.set(pipelines.error?.message || stages.error?.message || 'Unable to load pipelines.'); return; }
    this.pipelines.set((pipelines.data ?? []) as Pipeline[]); this.stages.set((stages.data ?? []) as Stage[]);
  }

  stagesFor(pipelineId: string): Stage[] { return this.stages().filter((stage) => stage.pipeline_id === pipelineId); }

  async addPipeline(): Promise<void> {
    const organizationId = this.auth.profile()?.organization_id; const userId = this.auth.profile()?.id;
    if (!organizationId || !userId || !this.permissions.isAdmin() || this.form.invalid || this.saving()) { this.form.markAllAsTouched(); return; }
    this.saving.set(true); this.errorMessage.set(null);
    const { error } = await this.supabase.from('pipelines').insert({ organization_id: organizationId, created_by: userId, ...this.form.getRawValue() });
    this.saving.set(false); if (error) { this.errorMessage.set(error.message); return; }
    this.form.reset({ name: '', description: '', color: '#2f6f6d' }); await this.loadPipelines();
  }

  async archivePipeline(pipeline: Pipeline): Promise<void> {
    const { error } = await this.supabase.from('pipelines').update({ archived_at: new Date().toISOString() }).eq('id', pipeline.id);
    if (error) { this.errorMessage.set(error.message); return; } await this.loadPipelines();
  }
}