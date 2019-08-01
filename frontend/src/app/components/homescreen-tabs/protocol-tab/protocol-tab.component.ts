import {Component, ViewChild} from "@angular/core";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";


@Component({
  templateUrl: './protocol-tab.html'
})
export class ProtocolTabComponent {
  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
}
