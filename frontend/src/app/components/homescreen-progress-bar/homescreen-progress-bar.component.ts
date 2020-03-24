import {Component, ElementRef, Input, OnInit, ViewChild} from '@angular/core';
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {input} from "reactivestates";


export const HomescreenProgressBarSelector = 'homescreen-progress-bar';

@Component({
  selector: HomescreenProgressBarSelector,
  templateUrl: './homescreen-progress-bar.html',
  styleUrls: ['./homescreen-progress-bar.sass']
})
export class HomescreenProgressBarComponent implements OnInit {
  @Input() column:any = '';
  @Input() cell_value:any = '';
  public $element:JQuery;
  public color:string = "#000";

  constructor(protected elementRef:ElementRef) { }

  ngOnInit() {
    // console.log(this.cell_value);
  }
}

DynamicBootstrapper.register({ selector: HomescreenProgressBarSelector, cls: HomescreenProgressBarComponent });
