import {HalResource} from 'core-app/modules/hal/resources/hal-resource';
import {Attachable} from 'core-app/modules/hal/resources/mixins/attachable-mixin';


export interface DynamicPageResourceLinks {
  addAttachment(attachment:HalResource):Promise<any>;
}

class DynamicPageBaseResource extends HalResource {
  public $links:DynamicPageResourceLinks;

  public canAddAttachments() {
    return true;
  }

  private attachmentsBackend = false;
}

export const DynamicPageResource = Attachable(DynamicPageBaseResource);

export interface DynamicPageResource extends HalResource {
}
