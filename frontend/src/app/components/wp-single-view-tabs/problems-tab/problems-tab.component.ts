import { Component, OnInit } from '@angular/core';
import {TimezoneService} from "core-components/datetime/timezone.service";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";

@Component({
  selector: 'problems-tab',
  templateUrl: './problems-tab.component.html',
})
export class WorkPackageProblemsTabComponent implements OnInit {

  public text = {
    problems_header: this.I18n.t('js.work_packages.tabs.problems')
  };

  constructor(readonly timezoneService:TimezoneService,
              protected I18n:I18nService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit() {
  }

}
