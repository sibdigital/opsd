import {Component, ViewChild} from "@angular/core";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";


@Component({
  templateUrl: './problems-tab.html'
})
export class ProblemsTabComponent {
  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
}
