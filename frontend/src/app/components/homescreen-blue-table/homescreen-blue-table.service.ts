import {BlueTableNationalProjectsService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-national-projects.service";
import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {BlueTableKtService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-kt.service";
import {BlueTableProblemsService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-problems.service";

export class HomescreenBlueTableService {

  constructor(public readonly blueTableNationalProjectsService:BlueTableNationalProjectsService,
              public readonly blueTableKtService:BlueTableKtService,
              public readonly blueTableProblemsService:BlueTableProblemsService) {

  }

  public getBlueTable(template:string):BlueTableService | null {
    if (template === 'desktop') {
      return this.blueTableNationalProjectsService;
    }
    if (template === 'kt') {
      return this.blueTableKtService;
    }
    if (template === 'problems') {
      return this.blueTableProblemsService;
    }
    return null;
  }
}
