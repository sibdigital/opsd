import {Component, Injector, OnInit, Input} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {BlueTableDesktopService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-desktop.service";
import {BlueTableKtService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-kt.service";
import {BlueTableProblemsService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-problems.service";
import {BlueTableKpiService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-kpi.service";
import {BlueTableDiscussService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-discuss.service";
import {BlueTableBudgetService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-budget.service";
import {BlueTableIndicatorService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-indicator.service";
import {BlueTableProtocolService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-protocol.service";
import {BlueTableMunicipalityService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-municipality.service";
import {BlueTablePerformanceService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-performance.service";
import {homescreenPerformanceDiagramSelector} from "core-components/homescreen-performance-diagram/homescreen-performance-diagram.component";

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
      this.columns = this.blueTableModule.getColumns();
      this.blueTableModule.initializeAndGetData().then((data) => {this.data = data; });
    }
  }

  public getBlueTable(template:string) {
    if (template === 'desktop') {
      this.blueTableModule = this.injector.get(BlueTableDesktopService);
    }
    if (template === 'kt') {
      this.blueTableModule = this.injector.get(BlueTableKtService);
    }
    if (template === 'problems') {
      this.blueTableModule  = this.injector.get(BlueTableProblemsService);
    }
    if (template === 'kpi') {
      this.blueTableModule  = this.injector.get(BlueTableKpiService);
    }
    if (template === 'discuss') {
      this.blueTableModule  = this.injector.get(BlueTableDiscussService);
    }
    if (template === 'budget') {
      this.blueTableModule  = this.injector.get(BlueTableBudgetService);
    }
    if (template === 'indicator') {
      this.blueTableModule  = this.injector.get(BlueTableIndicatorService);
    }
    if (template === 'protocol') {
      this.blueTableModule  = this.injector.get(BlueTableProtocolService);
    }
    if (template === 'performance') {
      this.blueTableModule  = this.injector.get(BlueTablePerformanceService);
    }
    if (template === 'municipality') {
      this.blueTableModule  = this.injector.get(BlueTableMunicipalityService);
    }
  }

  public loadPage(i:number) {
    this.blueTableModule.getDataFromPage(i).then((data:any[]) => {this.data = data; });
  }

  public limitDays(i:number) {
    this.blueTableModule.getDataWithFilter('limit' + i).then((data:any[]) => {this.data = data; });
  }

  public changeFilter(param:string) {
    this.blueTableModule.getDataWithFilter(param).then((data:any[]) => {this.data = data; });
  }

  public hello(i:number) {
    jQuery(homescreenPerformanceDiagramSelector).attr('performance-id', i);
    jQuery('button.changeChart').trigger('click');
  }
}
