import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {MatDialog, MatDialogConfig} from "@angular/material/dialog";
import {Organization} from "../organization.model";
import {OrganizationModalSelectorDialogComponent} from "./organization-modal-selector-dialog/organization-modal-selector-dialog.component";

@Component({
  selector: 'op-organization-modal-selector',
  templateUrl: './organization-modal-selector.component.html',
  styleUrls: ['./organization-modal-selector.component.sass']
})
export class OrganizationModalSelectorComponent implements OnInit {

  @Input() selectedOrganization:Organization | undefined;
  @Output() outputselectedOrganization = new EventEmitter<any>();
  disabled:boolean = false;

  constructor(public dialog:MatDialog) { }

  ngOnInit():void {
    //
  }

  chooseOrganization():void {
    let matDialogConfig:MatDialogConfig = {
      panelClass: "dialog-responsive",
      autoFocus: false
    };
    const dialogRef = this.dialog.open(OrganizationModalSelectorDialogComponent, matDialogConfig);

    dialogRef.afterClosed().subscribe(result => {
      if (result.data) {
        this.selectedOrganization = result.data;
        this.outputselectedOrganization.emit(result.data);
      }
    });
  }

  openOrganization(event:any) {
    event.stopPropagation();
    if (this.selectedOrganization) {
      window.open(window.appBasePath + "/admin/organizations/" + this.selectedOrganization.id + "/edit", "_blank");
    }
  }

  removeOrganization(event:any) {
    if (this.selectedOrganization !== undefined) {
      this.selectedOrganization = undefined;
      this.outputselectedOrganization.emit(null);
    }
  }

  setOrganization(organization:any) {
    if (organization) {
      this.selectedOrganization = organization;
    }
  }

  disableChoice() {
    this.disabled = true;
  }

  enableChoice() {
    this.disabled = false;
  }

}
