import { inject } from '@angular/core';
import { toObservable } from '@angular/core/rxjs-interop';
import { CanActivateFn, Router } from '@angular/router';
import { filter, firstValueFrom } from 'rxjs';
import { AuthService } from '../services/auth.service';

// Blocks access to authenticated areas until the initial Supabase session check resolves.
export const authGuard: CanActivateFn = async () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  await firstValueFrom(toObservable(auth.initialized).pipe(filter(Boolean)));

  return auth.isAuthenticated() ? true : router.createUrlTree(['/login']);
};
