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
    jQuery('.kontrolnie-tochki-menu-item').on('click', event => {
      this.$state.go('homescreen.kt', {"project": "1"});
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.riski-i-problemy-menu-item').on('click', event => {
      this.$state.go('homescreen.problems');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.kpi-menu-item').on('click', event => {
      this.$state.go('homescreen.kpi');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.obsuzhdeniya-menu-item').on('click', event => {
      this.$state.go('homescreen.discuss');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.ispolnenie-budzheta-menu-item').on('click', event => {
      this.$state.go('homescreen.budget');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.ispolnenie-pokazatelei-menu-item').on('click', event => {
      this.$state.go('homescreen.indicator');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.elektronnyi-protokol-menu-item').on('click', event => {
      this.$state.go('homescreen.protocol');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.municipalitet-menu-item').on('click', event => {
      this.$state.go('homescreen.municipality');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    });
    jQuery('.ocenka-deyatelnosti-menu-item').on('click', event => {
      this.$state.go('homescreen.performance');
      jQuery('.ellipsis, .selected').removeClass('selected');
      jQuery(event.currentTarget).addClass('selected');
    })
  }
}
