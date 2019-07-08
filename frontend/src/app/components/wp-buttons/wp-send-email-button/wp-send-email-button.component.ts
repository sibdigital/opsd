import {Component, Input, OnInit} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {CurrentProjectService} from "core-components/projects/current-project.service";
import {catchError} from "rxjs/operators";

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
              readonly currentProject:CurrentProjectService
  ) { }

  ngOnInit() {

    this.projectIdentifier = this.currentProject.identifier;

  }

  public sendEmail() {
    console.log("send test email...");


    this.http.get("http://localhost:3000/admin/send_email_assignee_from_task?workPackageId=" + this.workPackageId).subscribe(value =>{
        console.log("success");
      },
      error => {
        console.error('An error occurred:', error.error.message);

      });

    /*
    this.http.post("http://localhost:3000/admin/send_email_assignee_from_task",this.projectIdentifier).subscribe(value =>{
        console.log("success");
        },
        error => {
          console.error('An error occurred:', error.error.message);

        });
     */

/*
    toPromise().then (function(response) {d
      console.log("success");
      //$scope.status = response.status;
      //$scope.data = response.data;
    }, function(response) {
      console.log("error");
      //$scope.data = response.data || 'Request failed';
      //$scope.status = response.status;
    });
*/

  //  pipe(
 //     catchError(this.handleError('addHero', hero))
   // );

  }
}
