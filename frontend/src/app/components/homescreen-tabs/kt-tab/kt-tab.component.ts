import {Component, ViewChild} from "@angular/core";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";


@Component({
  templateUrl: './kt-tab.html'
})
export class KtTabComponent {
  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
}
