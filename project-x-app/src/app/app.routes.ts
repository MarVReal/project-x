import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { guestGuard } from './core/guards/guest.guard';
import { roleGuard } from './core/guards/role.guard';
import { FeaturePlaceholderComponent } from './shared/components/feature-placeholder/feature-placeholder.component';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/auth/pages/login/login.component').then((m) => m.LoginComponent),
  },
  {
    path: 'forgot-password',
    canActivate: [guestGuard],
    loadComponent: () =>
      import('./features/auth/pages/forgot-password/forgot-password.component').then(
        (m) => m.ForgotPasswordComponent
      ),
  },
  {
    path: 'reset-password',
    loadComponent: () =>
      import('./features/auth/pages/reset-password/reset-password.component').then(
        (m) => m.ResetPasswordComponent
      ),
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./layout/shell/shell.component').then((m) => m.ShellComponent),
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/pages/dashboard.component').then((m) => m.DashboardComponent),
      },
      {
        path: 'profile',
        loadComponent: () => import('./features/profile/pages/profile.component').then((m) => m.ProfileComponent),
      },
      {
        path: 'tasks',
        component: FeaturePlaceholderComponent,
        data: {
          title: 'Tasks',
          description: 'Task lists, boards, and calendar views arrive in Phase 5–8.',
          icon: 'checklist',
        },
      },
      {
        path: 'pipelines',
        component: FeaturePlaceholderComponent,
        data: {
          title: 'Pipelines',
          description: 'Pipeline and stage management arrives in Phase 4.',
          icon: 'account_tree',
        },
      },
      {
        path: 'teams',
        component: FeaturePlaceholderComponent,
        data: { title: 'Teams', description: 'Team/section management arrives in Phase 3.', icon: 'groups' },
      },
      {
        path: 'users',
        canActivate: [roleGuard(['admin'])],
        component: FeaturePlaceholderComponent,
        data: {
          title: 'Users',
          description: 'Admin user management and invitations arrive in Phase 3.',
          icon: 'manage_accounts',
        },
      },
      {
        path: 'tags',
        canActivate: [roleGuard(['admin'])],
        component: FeaturePlaceholderComponent,
        data: { title: 'Tags', description: 'Organization tag management arrives in Phase 3–5.', icon: 'sell' },
      },
      {
        path: 'notifications',
        component: FeaturePlaceholderComponent,
        data: {
          title: 'Notifications',
          description: 'In-app notifications arrive in Phase 10.',
          icon: 'notifications',
        },
      },
      {
        path: 'settings',
        canActivate: [roleGuard(['admin'])],
        component: FeaturePlaceholderComponent,
        data: { title: 'Settings', description: 'Organization settings arrive in a later phase.', icon: 'settings' },
      },
      { path: '**', redirectTo: 'dashboard' },
    ],
  },
  { path: '**', redirectTo: 'login' },
];
