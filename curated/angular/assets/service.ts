import { Injectable, signal, computed, inject } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { firstValueFrom } from "rxjs";

interface CartItem {
  id: string;
  name: string;
  price: number;
  qty: number;
}

interface CartState {
  items: CartItem[];
  loading: boolean;
  error: string | null;
}

@Injectable({ providedIn: "root" })
export class CartService {
  private readonly http = inject(HttpClient);

  // Private state signal
  private readonly state = signal<CartState>({
    items: [],
    loading: false,
    error: null,
  });

  // Public selectors (computed)
  readonly items = computed(() => this.state().items);
  readonly loading = computed(() => this.state().loading);
  readonly error = computed(() => this.state().error);
  readonly total = computed(() =>
    this.items().reduce((sum, i) => sum + i.price * i.qty, 0)
  );
  readonly count = computed(() => this.items().length);

  // Actions
  addItem(item: CartItem): void {
    this.state.update((s) => ({
      ...s,
      items: [...s.items, item],
    }));
  }

  removeItem(id: string): void {
    this.state.update((s) => ({
      ...s,
      items: s.items.filter((i) => i.id !== id),
    }));
  }

  async loadCart(): Promise<void> {
    this.state.update((s) => ({ ...s, loading: true, error: null }));
    try {
      const items = await firstValueFrom(
        this.http.get<CartItem[]>("/api/cart")
      );
      this.state.update((s) => ({ ...s, items, loading: false }));
    } catch {
      this.state.update((s) => ({
        ...s,
        loading: false,
        error: "Failed to load cart",
      }));
    }
  }
}
