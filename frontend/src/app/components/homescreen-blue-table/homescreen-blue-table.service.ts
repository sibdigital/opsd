import {BlueTableNationalProjectsService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-national-projects.service";
import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {BlueTableKtService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-kt.service";

export class HomescreenBlueTableService {

  constructor(public readonly blueTableNationalProjectsModule:BlueTableNationalProjectsService,
              public readonly blueTableKtModule:BlueTableKtService) {

  }

  public getBlueTable(template:string):BlueTableService | null {
    if (template === 'desktop') {
      return this.blueTableNationalProjectsModule;
    }
    if (template === 'kt') {
      return this.blueTableKtModule;
    }
    return null;
  }
}
