import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient} from "@angular/common/http";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {Position} from "core-components/organizations/schema";

@Component({
  selector: 'op-position-form',
  templateUrl: './position-form.component.html',
  styleUrls: ['./position-form.component.sass']
})
export class PositionFormComponent implements OnInit {
  public position = new Position();

  public answerJSON:any;
  public $element:JQuery;
  @Input() id:string;

  constructor(protected pathHelper:PathHelperService,
              protected httpClient:HttpClient,
              protected elementRef:ElementRef,
              private notificationService:NotificationsService) {
  }

  ngOnInit(): void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.id = this.$element.attr('id')!;
    this.id ? this.loadPosition() : null;
  }

  private loadPosition() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + `/positions/${this.id}`).toPromise()
      .then((response:Position) => {
        this.position = response;
      })
      .catch((reason) => console.error(reason));
  }

  savePosition() {
    this.httpClient.post(
      this.pathHelper.javaUrlPath + '/position/save', this.position).toPromise()
      .then((response:Position) => {
        this.position = response;
        this.notificationService.addSuccess('Изменения сохранены');
      })
      .catch((reason) => {
        this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
        console.error(reason);
      });
  }

}
DynamicBootstrapper.register({selector: 'op-position-form', cls: PositionFormComponent});
