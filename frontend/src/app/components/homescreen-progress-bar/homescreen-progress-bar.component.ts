import {Component, ElementRef, Input, OnInit, ViewChild} from '@angular/core';
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";


export const HomescreenProgressBarSelector = 'homescreen-progress-bar';

@Component({
  selector: HomescreenProgressBarSelector,
  templateUrl: './homescreen-progress-bar.html',
  styleUrls: ['./homescreen-progress-bar.sass']
})
export class HomescreenProgressBarComponent implements OnInit {
  @Input('progress') public progress:string;
  constructor() { }

  ngOnInit() {
    console.log(this.progress);
  }


}

DynamicBootstrapper.register({ selector: HomescreenProgressBarSelector, cls: HomescreenProgressBarComponent });
