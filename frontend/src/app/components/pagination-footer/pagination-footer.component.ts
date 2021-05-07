import {ChangeDetectionStrategy, Component, EventEmitter, Input, Output} from "@angular/core";

@Component({
  selector: 'pagination-footer',
  templateUrl: './pagination-footer.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class PaginationFooterComponent {
  @Input() public pages:number = 0;
  public page:number = 1;
  @Output() changePageEvent = new EventEmitter<number>();
  public goto = false;
  destination:any;

  loadPage(page:number) {
    if (this.page !== page) {
      this.page = page;
      this.changePageEvent.emit(page);
    }
  }

  toPage() {
    this.goto = true;
  }

  goTo() {
    if (!(this.destination < 1 || this.destination > this.pages)) {
      this.goto = false;
      this.loadPage(this.destination);
    }
  }
}
