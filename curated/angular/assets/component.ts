import {
  Component,
  ChangeDetectionStrategy,
  signal,
  computed,
  input,
  output,
  inject,
} from "@angular/core";
import { CurrencyPipe } from "@angular/common";

interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
}

@Component({
  selector: "app-product-list",
  imports: [CurrencyPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (loading()) {
      <div class="spinner">Loading...</div>
    } @else {
      @for (product of filtered(); track product.id) {
        <div class="product-card" (click)="select(product)">
          <h3>{{ product.name }}</h3>
          <p>{{ product.price | currency }}</p>
        </div>
      } @empty {
        <p>No products found</p>
      }
    }
  `,
})
export class ProductListComponent {
  // Inputs
  readonly category = input<string>();
  readonly products = input.required<Product[]>();

  // Outputs
  readonly productSelected = output<Product>();

  // Internal state (private signal, public readonly)
  private readonly _loading = signal(false);
  readonly loading = this._loading.asReadonly();

  // Computed (derived state)
  readonly filtered = computed(() => {
    const cat = this.category();
    return cat
      ? this.products().filter((p) => p.category === cat)
      : this.products();
  });

  select(product: Product): void {
    this.productSelected.emit(product);
  }
}
