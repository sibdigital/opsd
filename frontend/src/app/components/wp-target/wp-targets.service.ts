import {WpTargetResource} from 'core-app/modules/hal/resources/wp-target-resource';
import {WorkPackageResource} from 'core-app/modules/hal/resources/work-package-resource';
import {PathHelperService} from 'core-app/modules/common/path-helper/path-helper.service';
import {Injectable} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {WpTargetsDmService} from "core-app/modules/hal/dm-services/wp-targets-dm.service";
import {TargetResource} from "core-app/modules/hal/resources/target-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {RelationResource} from "core-app/modules/hal/resources/relation-resource";
import {WorkPackageTableRefreshService} from "core-components/wp-table/wp-table-refresh-request.service";


@Injectable()
export class WpTargetsService {

  constructor(private targetsDm:WpTargetsDmService,
              private pathHelper:PathHelperService,
              private wpTableRefresh:WorkPackageTableRefreshService,
              private halResourceService:HalResourceService) {
  }

  /** Возвращает данные из targets
   * */
  getTargets(project_id: string){
    return this.halResourceService
      .get<CollectionResource<TargetResource>>(this.pathHelper.api.v3.targets.toString() + '?project_id=' + project_id)
      .toPromise()
      .then((collection:CollectionResource<TargetResource>) => collection.elements);
  }

  /** Добавляет новую запись в work_package_targets
   * */
  addWpTarget(workPackageId: string, projectId: string, targetId: string,
              year: number, quarter: number, month: number, planValue: number, val: number){
    //const path = pathHelper.api.v3.work_package_targets.id(fromId).relations.toString();
    const params = {project_id: projectId, work_package_id: workPackageId, target_id: targetId,
                  year: year, quarter: quarter, month: month, plan_value: planValue, value: val};
    const path = this.pathHelper.api.v3.work_packages.toString() + '/' + workPackageId + '/work_package_targets';
    return this.halResourceService
      .post<WpTargetResource>(path, params)
      .toPromise()
      .then((wpTarget:WpTargetResource) => {
        //insertIntoStates(relation);
        //wpTableRefresh.request(
        //  ``,
        //  true
        //);
        return wpTarget;
      });
  }
}
