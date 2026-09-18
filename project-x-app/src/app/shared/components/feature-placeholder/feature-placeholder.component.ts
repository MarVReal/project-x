import { Component, input } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';

// Generic "coming soon" screen used by features not yet implemented in the current phase.
@Component({
  selector: 'app-feature-placeholder',
  standalone: true,
  imports: [MatCardModule, MatIconModule],
  templateUrl: './feature-placeholder.component.html',
  styleUrl: './feature-placeholder.component.scss',
})
export class FeaturePlaceholderComponent {
  readonly title = input.required<string>();
  readonly description = input<string>('This area will be implemented in an upcoming development phase.');
  readonly icon = input<string>('construction');
}
