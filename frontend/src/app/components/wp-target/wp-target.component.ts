import {Component, Input, OnDestroy, OnInit} from '@angular/core';
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {TargetResource} from "core-app/modules/hal/resources/target-resource";
import {ValueOption} from "core-components/wp-overview-diagram/overview-diagram-tab/overview-diagram-tab.component";
import {TimezoneService} from "core-components/datetime/timezone.service";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {takeUntil} from "rxjs/operators";
import {componentDestroyed} from "ng2-rx-componentdestroyed";
import {Transition} from "@uirouter/core";
import {WorkPackageCacheService} from "core-components/work-packages/work-package-cache.service";

export interface ValueOption {
  name:string;
  id:string;
}

@Component({
  selector: 'wp-target',
  templateUrl: './wp-target.html',
})
export class WpTargetComponent implements OnInit, OnDestroy {
  @Input() public workPackageId:string;
  @Input() public workPackage:WorkPackageResource;

  public project_id: number;
  public work_package_id: number;
  public target_id: number;
  public year: number;
  public quarter: number;
  public plan_value: number;
  public value: number;


  public targetSelect:ValueOption | undefined;
  public targetSelectOptions:ValueOption[] = [];

  constructor(readonly timezoneService:TimezoneService,
              protected I18n:I18nService,
              readonly $transition:Transition,
              readonly wpCacheService:WorkPackageCacheService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit() {
    // const wpId = this.workPackageId || this.$transition.params('to').workPackageId;
    // this.wpCacheService.loadWorkPackage(wpId)
    //   .values$()
    //   .pipe(
    //     takeUntil(componentDestroyed(this))
    //   )
    //   .subscribe((wp) => {
    //     this.workPackageId = wp.id;
    //     this.workPackage = wp;
    //   });

    this.getTargets().then((resources:CollectionResource<TargetResource>) => {
      let els = resources.elements;
      this.targetSelectOptions = els.map(el => {
        return {name: el.name, id: el.getId()};
      });
    });

    this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.wpBySubjectOrId(this.workPackageId, true).toString() + '/work_package_targets')
      .toPromise()
      .then((resource:HalResource) => {
        this.project_id = resource.project_id;
        this.work_package_id = resource.work_package_id;
        this.target_id = resource.target_id;
        this.year = resource.year;
        this.quarter = resource.quarter;
        this.plan_value = resource.plan_value;
        this.value = resource.value;
      });
  }

  public ngOnDestroy(): void {
  }

  private getTargets():Promise<CollectionResource<TargetResource>> {
    return this.halResourceService
      .get<CollectionResource<TargetResource>>(this.pathHelper.api.v3.wpBySubjectOrId(this.workPackageId, true).toString() + '/work_package_targets')
      .toPromise();
  }


}
