import {WpTargetResource} from 'app/modules/hal/resources/wp-target-resource';
import {WorkPackageResource} from 'app/modules/hal/resources/work-package-resource';
import {PathHelperService} from 'app/modules/common/path-helper/path-helper.service';
import {Injectable} from "@angular/core";
import {HalResourceService} from "app/modules/hal/services/hal-resource.service";
import {WpTargetsDmService} from "app/modules/hal/dm-services/wp-targets-dm.service";
import {TargetResource} from "app/modules/hal/resources/target-resource";
import {CollectionResource} from "app/modules/hal/resources/collection-resource";
import {HalResource} from "app/modules/hal/resources/hal-resource";


@Injectable()
export class WpTargetsService {

  constructor(private targetsDm:WpTargetsDmService,
              private pathHelper:PathHelperService,
              private halResourceService:HalResourceService) {
  }

  /** Возвращает данные из targets
   * */
  getTargets(project_id: string){
    return this.halResourceService
      .get<CollectionResource<TargetResource>>(this.pathHelper.api.v3.targets.toString(), {'project_id': project_id})
      .toPromise()
      .then((collection:CollectionResource<TargetResource>) => collection.elements);
  }

  /** Возвращает список work_package_targets
   * */
  getWpTargets(workPackageId: string){
    //let wpTargets: WpTargetResource[];

    return this.halResourceService
      // .get<HalResource>(this.pathHelper.api.v3.work_packages.toString() + '/' + workPackageId + '/work_package_targets')
      .get<HalResource>(this.pathHelper.api.v3.work_package_targets.toString(), {'work_package_id': workPackageId})
      .toPromise();
      //.then((collection:CollectionResource<WpTargetResource>) => collection.elements);
      // .then((resource:HalResource) => {
      //   let els = resource.elements;
      //   wpTargets = els.map( (el: any) => {
      //       if(this.wpTargetsIds.indexOf(Number(el.targetId)) === -1){
      //         this.wpTargetsIds.push(el.targetId);
      //       }
      //       return {
      //         project_id: el.projectId,
      //         work_package_id: el.workPackageId,
      //         wp_target_id: el.targetId,
      //         year: el.year,
      //         quarter: el.quarter,
      //         plan_value: el.planValue,
      //         value: el.value
      //       }
      //     }
      //   );
      //   console.log(wpTargets);
      //   return wpTargets;
      //   //console.log(this.wpTargets);
      //   //console.log(this.wpTargetIds);
      // });
  }

  /** Добавляет новую запись в work_package_targets
   * */
  addWpTarget(workPackageId: string, projectId: string, targetId: string,
              year: number, quarter: number, month: number, planValue: number, val: number){
    const params = {project_id: projectId, work_package_id: workPackageId, target_id: targetId,
                  year: year, quarter: quarter, month: month, plan_value: planValue, value: val};
    const path = this.pathHelper.api.v3.work_package_targets.toString();
    return this.halResourceService
      .post<WpTargetResource>(path, params)
      .toPromise();
      // .then((wpTarget:WpTargetResource) => {
      //  return wpTarget;
      // });
  }
}
