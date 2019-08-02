import {Component, Input, OnDestroy, OnInit} from '@angular/core';
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {TimezoneService} from "core-components/datetime/timezone.service";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {WpTargetResource} from "core-app/modules/hal/resources/wp-target-resource";
import {TargetResource} from "core-app/modules/hal/resources/target-resource";
import {WpTargetsService} from "core-components/wp-target/wp-targets.service";

@Component({
  selector: 'wp-target',
  templateUrl: './wp-target.html',
})

export class WpTargetComponent implements OnInit, OnDestroy {
  @Input() public workPackageId:string;
  @Input() public workPackage:WorkPackageResource;

  //public targetSelectOptions = new Map();

  public wpTargets: WpTargetResource[];
  public wpTargetIds: number[] = [];

  public text = {
    targets_header: this.I18n.t('js.work_packages.tabs.targets')
  };

  constructor(readonly timezoneService:TimezoneService,
              protected I18n:I18nService,
              protected wpTargetsService:WpTargetsService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit() {

    //this.getTargets().then((resources:CollectionResource<TargetResource>) => {
    // this.wpTargetsService.getTargets(this.workPackage.project.id).then((resources:CollectionResource<TargetResource>) => {
    //   let els = resources.elements;
    //   els.forEach(el =>
    //     {this.targetSelectOptions.set(Number(el.getId()), el.name)}
    //   );
    // });

    this.wpTargetsService.getWpTargets(this.workPackageId)
      .then((resource:HalResource) => {
        let els = resource.elements;
        this.wpTargets = els.map( (el:any) => {
            if(this.wpTargetIds.indexOf(Number(el.targetId)) === -1){
              this.wpTargetIds.push(el.targetId);
            }
            return {
              project_id: el.projectId,
              work_package_id: el.workPackageId,
              wp_target_id: el.targetId,
              year: el.year,
              quarter: el.quarter,
              plan_value: el.planValue,
              value: el.value,
              name: el.$links.self.title
            }
           }
        );
        //console.log(this.wpTargets);
        //console.log(this.wpTargetIds);
    });
  }

  public ngOnDestroy(): void {
  }

  // private getTargets():Promise<CollectionResource<TargetResource>> {
  //   return this.halResourceService
  //     .get<CollectionResource<TargetResource>>(this.pathHelper.api.v3.targets.toString(), {project_id: this.workPackage.project.id})
  //     .toPromise();
  // }
}
