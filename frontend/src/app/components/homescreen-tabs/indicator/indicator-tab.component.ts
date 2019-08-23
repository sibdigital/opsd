import {Component} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";


@Component({
  templateUrl: './indicator-tab.html'
})
export class IndicatorTabComponent {
  constructor(readonly I18n:I18nService) {
  }
}
