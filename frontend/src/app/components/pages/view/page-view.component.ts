import {Component} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";

@Component({
  selector: 'op-page-view',
  templateUrl: './page-view.component.html',
  styleUrls: ['./page-view.component.sass']
})
export class PageViewComponent {
  constructor() {
    console.log('PageViewComponent works!');
  }
}
DynamicBootstrapper.register({selector: 'op-page-view', cls: PageViewComponent});
