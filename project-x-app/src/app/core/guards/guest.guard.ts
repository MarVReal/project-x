import { inject } from '@angular/core';
import { toObservable } from '@angular/core/rxjs-interop';
import { CanActivateFn, Router } from '@angular/router';
import { filter, firstValueFrom } from 'rxjs';
import { AuthService } from '../services/auth.service';

// Keeps already-authenticated users off public pages like /login.
export const guestGuard: CanActivateFn = async () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  await firstValueFrom(toObservable(auth.initialized).pipe(filter(Boolean)));

  return auth.isAuthenticated() ? router.createUrlTree(['/dashboard']) : true;
};
