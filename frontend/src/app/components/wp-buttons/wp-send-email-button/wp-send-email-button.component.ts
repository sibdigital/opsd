import {Component, Input, OnInit} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";

@Component({
  selector: 'app-wp-send-email-button',
  templateUrl: './wp-send-email-button.component.html',
  styleUrls: ['./wp-send-email-button.component.css']
})
export class WpSendEmailButtonComponent implements OnInit {
  @Input('workPackageId') public workPackageId:string;

  public label_text:string = "Отправить напоминание";

  public projectIdentifier:string|null;

  constructor(readonly http:HttpClient,
              protected NotificationsService:NotificationsService,
              private readonly PathHelper:PathHelperService
  ) { }

  ngOnInit() {
  }

  public sendEmail() {

    const url = this.PathHelper.appBasePath + '/admin/send_email_assignee_from_task?workPackageId=' + this.workPackageId;

    const promise = this.http.get(url).toPromise();

    promise
      .then((response) => {
        //this.NotificationsService.addSuccess(this.text.successful_delete);
        this.NotificationsService.addSuccess("Уведомление отправлено");
      })
      .catch((error) => {
        window.location.href = url;
        this.NotificationsService.addError(error);
      });

  }
}
