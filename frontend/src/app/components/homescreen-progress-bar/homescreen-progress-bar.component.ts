import {Component, ElementRef, Input, OnInit, ViewChild} from '@angular/core';
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";


export const HomescreenProgressBarSelector = 'homescreen-progress-bar';

@Component({
  selector: HomescreenProgressBarSelector,
  templateUrl: './homescreen-progress-bar.html',
  styleUrls: ['./homescreen-progress-bar.sass']
})
export class HomescreenProgressBarComponent implements OnInit {
  @Input('progress') public progress:string = '';
  public $element:JQuery;
  public color:string = "#000"

  constructor(protected elementRef:ElementRef) { }

  ngOnInit() {
    if (parseInt(this.progress) < 30) {
      this.color = '#ee8888';
    } else if (parseInt(this.progress) < 60) {
      this.color = '#eeee88';
    } else {
      this.color = '#88ee88';
    }
    this.$element = jQuery(this.elementRef.nativeElement);
    this.$element.children().children('.progress').attr('data-label', this.progress + '%');
  }


}

DynamicBootstrapper.register({ selector: HomescreenProgressBarSelector, cls: HomescreenProgressBarComponent });
