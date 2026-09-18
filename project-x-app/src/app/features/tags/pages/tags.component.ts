import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { AuthService } from '../../../core/services/auth.service';
import { SupabaseClientService } from '../../../core/services/supabase-client.service';

interface Tag { id: string; name: string; color: string; description: string | null; }

@Component({ selector: 'app-tags', standalone: true, imports: [ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule], templateUrl: './tags.component.html', styleUrl: './tags.component.scss' })
export class TagsComponent {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly supabase = inject(SupabaseClientService).client;
  readonly tags = signal<Tag[]>([]);
  readonly loading = signal(true);
  readonly saving = signal(false);
  readonly errorMessage = signal<string | null>(null);
  readonly form = this.fb.nonNullable.group({ name: ['', [Validators.required, Validators.maxLength(100)]], color: ['#2f6f6d', Validators.required], description: [''] });

  constructor() { void this.loadTags(); }

  async loadTags(): Promise<void> {
    const organizationId = this.auth.profile()?.organization_id;
    if (!organizationId) { this.loading.set(false); return; }
    const { data, error } = await this.supabase.from('tags').select('id, name, color, description').eq('organization_id', organizationId).is('archived_at', null).order('name');
    this.loading.set(false);
    if (error) { this.errorMessage.set(error.message); return; }
    this.tags.set((data ?? []) as Tag[]);
  }

  async addTag(): Promise<void> {
    const organizationId = this.auth.profile()?.organization_id;
    const userId = this.auth.profile()?.id;
    if (!organizationId || !userId || this.form.invalid || this.saving()) { this.form.markAllAsTouched(); return; }
    this.saving.set(true); this.errorMessage.set(null);
    const { error } = await this.supabase.from('tags').insert({ organization_id: organizationId, created_by: userId, ...this.form.getRawValue() });
    this.saving.set(false);
    if (error) { this.errorMessage.set(error.message); return; }
    this.form.reset({ name: '', color: '#2f6f6d', description: '' });
    await this.loadTags();
  }

  async archiveTag(tag: Tag): Promise<void> {
    const { error } = await this.supabase.from('tags').update({ archived_at: new Date().toISOString() }).eq('id', tag.id);
    if (error) { this.errorMessage.set(error.message); return; }
    await this.loadTags();
  }
}