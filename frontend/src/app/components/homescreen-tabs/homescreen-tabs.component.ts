import {Component, Injector, OnInit} from "@angular/core";
import {States} from "core-components/states.service";
import {StateService} from "@uirouter/core";

export const homescreenTabsSelector = 'homescreen-tabs';

@Component({
  selector: homescreenTabsSelector,
  templateUrl: './homescreen-tabs.html'
})
export class HomescreenTabsComponent implements OnInit {
  constructor(public injector:Injector,
              public states:States,
              readonly $state:StateService) { }

  ngOnInit():void {
    jQuery('.rabocii-stol-menu-item').on('click', event => {
      this.$state.go('homescreen.desktop');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.kpi-menu-item').on('click', event => {
      this.$state.go('homescreen.kpi');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
  }
}
