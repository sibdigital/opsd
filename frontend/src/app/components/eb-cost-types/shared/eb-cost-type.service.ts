import {Injectable} from "@angular/core";
import {HttpClient, HttpParams} from "@angular/common/http";
import {environment} from "../../../../environments/environment";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {RegEbCostType} from "core-components/eb-cost-types/reg-eb-cost-types.model";

@Injectable({
  providedIn: 'root'
})
export class EbCostTypeService {

  constructor(protected pathHelper:PathHelperService,
              protected httpClient:HttpClient) { }
  getRegEbCostTypesWithAdditionalEbCT() {
    return this.httpClient.get<RegEbCostType[]>(this.pathHelper.javaUrlPath + '/rebCostTypesWithAdditionalEbCT');
  }
}
