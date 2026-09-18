import { Component, computed, inject } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { AuthService } from '../../../core/services/auth.service';
import { PermissionService } from '../../../core/services/permission.service';

// Real KPI cards are wired up to Supabase queries in Phase 9 (dashboards). This establishes the layout.
@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [MatCardModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent {
  private readonly auth = inject(AuthService);
  private readonly permissions = inject(PermissionService);

  readonly displayName = computed(() => this.auth.profile()?.full_name || this.auth.currentUser()?.email);
  readonly role = this.permissions.role;

  readonly kpiCards = computed(() => {
    if (this.permissions.isAdmin()) {
      return [
        'Total tasks',
        'Completed tasks',
        'Overdue tasks',
        'Tasks due today',
        'Tasks due this week',
        'Tasks by priority',
      ];
    }
    if (this.permissions.isSectionHead()) {
      return ['Section tasks', 'Completed tasks', 'Overdue tasks', 'Staff workload', 'Upcoming deadlines'];
    }
    return ['My tasks', 'Due today', 'Upcoming', 'Overdue', 'Recently completed'];
  });
}
