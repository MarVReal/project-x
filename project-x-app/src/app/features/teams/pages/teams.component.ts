import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { AuthService } from '../../../core/services/auth.service';
import { PermissionService } from '../../../core/services/permission.service';
import { SupabaseClientService } from '../../../core/services/supabase-client.service';

interface Team {
  id: string;
  name: string;
  description: string | null;
  archived_at: string | null;
}

@Component({
  selector: 'app-teams',
  standalone: true,
  imports: [ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatIconModule, MatInputModule],
  templateUrl: './teams.component.html',
  styleUrl: './teams.component.scss',
})
export class TeamsComponent {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  readonly permissions = inject(PermissionService);
  private readonly supabase = inject(SupabaseClientService).client;

  readonly teams = signal<Team[]>([]);
  readonly loading = signal(true);
  readonly saving = signal(false);
  readonly errorMessage = signal<string | null>(null);
  readonly form = this.fb.nonNullable.group({ name: ['', [Validators.required, Validators.maxLength(150)]], description: [''] });

  constructor() {
    void this.loadTeams();
  }

  async loadTeams(): Promise<void> {
    const organizationId = this.auth.profile()?.organization_id;
    if (!organizationId) {
      this.loading.set(false);
      return;
    }

    const { data, error } = await this.supabase
      .from('teams')
      .select('id, name, description, archived_at')
      .eq('organization_id', organizationId)
      .is('archived_at', null)
      .order('name');

    this.loading.set(false);
    if (error) {
      this.errorMessage.set(error.message);
      return;
    }
    this.teams.set((data ?? []) as Team[]);
  }

  async addTeam(): Promise<void> {
    const organizationId = this.auth.profile()?.organization_id;
    if (!organizationId || !this.permissions.isAdmin() || this.form.invalid || this.saving()) {
      this.form.markAllAsTouched();
      return;
    }

    this.saving.set(true);
    this.errorMessage.set(null);
    const { error } = await this.supabase.from('teams').insert({ organization_id: organizationId, ...this.form.getRawValue() });
    this.saving.set(false);
    if (error) {
      this.errorMessage.set(error.message);
      return;
    }
    this.form.reset();
    await this.loadTeams();
  }

  async archiveTeam(team: Team): Promise<void> {
    if (!this.permissions.isAdmin()) return;
    const { error } = await this.supabase.from('teams').update({ archived_at: new Date().toISOString() }).eq('id', team.id);
    if (error) {
      this.errorMessage.set(error.message);
      return;
    }
    await this.loadTeams();
  }
}