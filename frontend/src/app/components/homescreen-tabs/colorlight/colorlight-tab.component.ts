import {Component, OnInit} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HttpClient, HttpParams} from "@angular/common/http";

@Component({
  selector: 'colorlight-tab',
  templateUrl: './colorlight-tab.html',
})
export class ColorlightTabComponent implements OnInit {
  types:any;
  types2:any;
  selectedValue:string;
  selectedValue2:string;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              protected http:HttpClient) {
  }

  ngOnInit() {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.enumerations.toString() + '/ArbitaryObjectType', {})
      .toPromise()
      .then((resource:CollectionResource<HalResource>) => {
        this.types = resource.elements;
        this.selectedValue = resource.elements[0].id;

        this.types2 = resource.elements;
        this.selectedValue2 = resource.elements[0].id;
      });
  }

  submit() {
    this.halResourceService
      .get<any>(this.pathHelper.api.v3.colorlight.toString(), {type: this.selectedValue})
      .toPromise()
      .then((resource:{ path:string }) => {
        this.http.get(this.pathHelper.api.v3.vkladka1.toString(), {
          responseType: 'blob',
          params: {filepath: resource.path}
        }).subscribe(file => {
          const filename = resource.path.substring(resource.path.lastIndexOf('/') + 1);
          this.downloadFile(file, filename);
        });
      });
  }

  downloadFile(file:any, filename:string):void {
    const blob = new Blob([file], {type: 'application/ms-excel'});
    const url = window.URL.createObjectURL(blob);
    let a = document.createElement('a');
    document.body.appendChild(a);
    // a.style = 'display: none';
    a.href = url;
    a.download = filename;
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  }


  submitsecond() {
    let params = new HttpParams().set("typeId", this.selectedValue);
    this.http.get(this.pathHelper.javaUrlPath + '/generate_light_report/xlsx/params?', {
      params: params,
      // observe: 'response',
      responseType: 'arraybuffer'
    }).toPromise().then(
      (data) => {
        this.downloadFile(data, "colorlight.xlsx");
      }
    );
  }
}
