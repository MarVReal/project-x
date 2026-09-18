import { Component, effect, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatChipsModule } from '@angular/material/chips';
import { AuthService } from '../../../core/services/auth.service';
import { SupabaseClientService } from '../../../core/services/supabase-client.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [ReactiveFormsModule, MatCardModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatChipsModule],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
})
export class ProfileComponent {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly supabase = inject(SupabaseClientService).client;

  readonly profile = this.auth.profile;
  readonly saving = signal(false);
  readonly successMessage = signal<string | null>(null);
  readonly errorMessage = signal<string | null>(null);

  readonly form = this.fb.nonNullable.group({
    full_name: ['', Validators.required],
  });

  constructor() {
    effect(() => {
      const profile = this.profile();
      if (profile) {
        this.form.patchValue({ full_name: profile.full_name }, { emitEvent: false });
      }
    });
  }

  async save(): Promise<void> {
    const profile = this.profile();
    if (!profile || this.form.invalid || this.saving()) {
      this.form.markAllAsTouched();
      return;
    }

    this.saving.set(true);
    this.successMessage.set(null);
    this.errorMessage.set(null);

    const { error } = await this.supabase
      .from('profiles')
      .update({ full_name: this.form.getRawValue().full_name })
      .eq('id', profile.id);

    this.saving.set(false);

    if (error) {
      this.errorMessage.set(error.message);
      return;
    }

    await this.auth.refreshProfile();
    this.successMessage.set('Profile updated.');
  }
}
