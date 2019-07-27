import {Component, Injector, OnInit, Input} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {BlueTableNationalProjectsService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-national-projects.service";
import {BlueTableKtService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-kt.service";

@Component({
  selector: 'homescreen-blue-table',
  templateUrl: './homescreen-blue-table.html',
  styleUrls: ['./homescreen-blue-table.sass']
})
export class HomescreenBlueTableComponent implements OnInit {
  @Input('template') public template:string;
  public blueTableModule:BlueTableService;
  public columns:string[] = [];
  public data:any[] = [];

  constructor(public readonly injector:Injector,
              protected I18n:I18nService) {
  }

  ngOnInit() {
    this.getBlueTable(this.template);
    if (!!this.blueTableModule) {
      this.data = this.blueTableModule.getData();
      this.columns = this.blueTableModule.getColumns();
    }
  }

  public getBlueTable(template:string) {
    if (template === 'desktop') {
      this.blueTableModule = this.injector.get(BlueTableNationalProjectsService);
    }
    if (template === 'kt') {
      this.blueTableModule = this.injector.get(BlueTableKtService);
    }
  }
  public loadPage(i:number) {
    if ( i === 0) {
      this.data = this.blueTableModule.getDataFromPage(1);
    } else if (i > this.blueTableModule.getPages()) {
      this.data = this.blueTableModule.getDataFromPage(this.blueTableModule.getPages());
    } else {
      this.data = this.blueTableModule.getDataFromPage(i);
    }
  }
}
