import { inject } from '@angular/core';
import { toObservable } from '@angular/core/rxjs-interop';
import { CanActivateFn, Router } from '@angular/router';
import { filter, firstValueFrom } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { PermissionService } from '../services/permission.service';
import { UserRole } from '../models';

// Route-level authorization only — the real boundary is Supabase RLS.
export function roleGuard(allowedRoles: UserRole[]): CanActivateFn {
  return async () => {
    const auth = inject(AuthService);
    const permissions = inject(PermissionService);
    const router = inject(Router);

    await firstValueFrom(toObservable(auth.initialized).pipe(filter(Boolean)));

    return permissions.hasRole(...allowedRoles) ? true : router.createUrlTree(['/dashboard']);
  };
}
