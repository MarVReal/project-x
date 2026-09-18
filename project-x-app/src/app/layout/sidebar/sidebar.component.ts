import { Component, computed, inject } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { PermissionService } from '../../core/services/permission.service';

interface NavItem {
  label: string;
  icon: string;
  route: string;
  visible: () => boolean;
}

// Sidebar navigation is permission-aware: items are hidden (not just disabled) when unauthorized.
@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [RouterLink, RouterLinkActive, MatListModule, MatIconModule],
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.scss',
})
export class SidebarComponent {
  private readonly permissions = inject(PermissionService);

  private readonly allNavItems: NavItem[] = [
    { label: 'Dashboard', icon: 'dashboard', route: '/dashboard', visible: () => true },
    { label: 'Tasks', icon: 'checklist', route: '/tasks', visible: () => true },
    { label: 'Pipelines', icon: 'account_tree', route: '/pipelines', visible: () => true },
    { label: 'Teams', icon: 'groups', route: '/teams', visible: () => true },
    { label: 'Users', icon: 'manage_accounts', route: '/users', visible: () => this.permissions.canManageUsers() },
    { label: 'Tags', icon: 'sell', route: '/tags', visible: () => this.permissions.canManageTags() },
    { label: 'Notifications', icon: 'notifications', route: '/notifications', visible: () => true },
    {
      label: 'Settings',
      icon: 'settings',
      route: '/settings',
      visible: () => this.permissions.canManageOrganizationSettings(),
    },
  ];

  readonly navItems = computed(() => this.allNavItems.filter((item) => item.visible()));
}
