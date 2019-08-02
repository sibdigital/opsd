import {HalResource} from 'core-app/modules/hal/resources/hal-resource';
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export interface WorkPackageTargetResourceEmbedded {
}


export interface WorkPackageTargetResourceLinks extends WorkPackageTargetResourceEmbedded {
}

export class WorkPackageTargetResource extends HalResource {
  public $embedded:WorkPackageTargetResourceEmbedded;
  public $links:WorkPackageTargetResourceLinks;

  readonly I18n:I18nService = this.injector.get(I18nService);

}
