import {Directive, ElementRef, Input} from '@angular/core';
import {StateService} from '@uirouter/core';
import {LinkHandling} from 'core-app/modules/common/link-handling/link-handling';
import {AuthorisationService} from 'core-app/modules/common/model-auth/model-auth.service';
import {PathHelperService} from 'core-app/modules/common/path-helper/path-helper.service';
import {WorkPackageResource} from 'core-app/modules/hal/resources/work-package-resource';
import {HookService} from 'core-app/modules/plugins/hook-service';
import {WpDestroyModal} from 'core-components/modals/wp-destroy-modal/wp-destroy.modal';
import {OpContextMenuTrigger} from 'core-components/op-context-menu/handlers/op-context-menu-trigger.directive';
import {OPContextMenuService} from 'core-components/op-context-menu/op-context-menu.service';
import {OpContextMenuItem} from 'core-components/op-context-menu/op-context-menu.types';
import {PERMITTED_CONTEXT_MENU_ACTIONS} from 'core-components/op-context-menu/wp-context-menu/wp-static-context-menu-actions';
import {OpModalService} from 'core-components/op-modals/op-modal.service';
import {WorkPackageAuthorization} from 'core-components/work-packages/work-package-authorization.service';
import {WorkPackageAction} from 'core-components/wp-table/context-menu-helper/wp-context-menu-helper.service';
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {HttpClient} from "@angular/common/http";
import {ResponseContentType} from "@angular/http";

@Directive({
  selector: '[wpSingleContextMenu]'
})
export class WorkPackageSingleContextMenuDirective extends OpContextMenuTrigger {
  @Input('wpSingleContextMenu-workPackage') public workPackage:WorkPackageResource;

  constructor(readonly HookService:HookService,
              readonly $state:StateService,
              readonly PathHelper:PathHelperService,
              readonly elementRef:ElementRef,
              readonly opModalService:OpModalService,
              protected notificationsService:NotificationsService,
              protected httpClient:HttpClient,
              protected pathHelper:PathHelperService,
              readonly opContextMenuService:OPContextMenuService,
              readonly authorisationService:AuthorisationService) {
    super(elementRef, opContextMenuService);
  }

  protected open(evt:JQueryEventObject) {
    this.workPackage.project.$load().then(() => {
      this.authorisationService.initModelAuth('work_package', this.workPackage.$links);

      var authorization = new WorkPackageAuthorization(this.workPackage, this.PathHelper, this.$state);
      const permittedActions = this.getPermittedActions(authorization);

      this.buildItems(permittedActions);
      this.opContextMenu.show(this, evt);
    });
  }

  public triggerContextMenuAction(action:WorkPackageAction, key:string) {
    const link = action.link;
    switch (key) {
      case 'copy':
        this.$state.go('work-packages.copy', {copiedFromWorkPackageId: this.workPackage.id});
        break;
      case 'delete':
        this.opModalService.show(WpDestroyModal, {workPackages: [this.workPackage]});
        break;
      case 'export-eb':
        this.httpClient.get(link, {responseType: 'blob' as 'json'})
          .subscribe(
            (data) => {
                var downloadURL = window.URL.createObjectURL(data);
                var link = document.createElement('a');
                link.href = downloadURL;
                var date = new Date();
                link.download = this.workPackage.name + "__" + date.toISOString() + ".XML";
                link.click();
            },
            error => {
              error.error.text().then(
                (errMessage:any) => {
                  let errObj = JSON.parse(errMessage);
                  if (errObj.status === "no meta id" && errObj.cause) {
                    this.notificationsService.addError(errObj.cause);
                  }
                  else {
                    this.notificationsService.addError('Не удалось скачать файл.');
                  }
                });
            }
        );
        break;
      default:
        window.location.href = link;
        break;
    }
  }

  /**
   * Positioning args for jquery-ui position.
   *
   * @param {Event} openerEvent
   */
  public positionArgs(evt:JQueryEventObject) {
    let additionalPositionArgs = {
      my: 'right top',
      at: 'right bottom'
    };

    let position = super.positionArgs(evt);
    _.assign(position, additionalPositionArgs);

    return position;
  }

  private getPermittedActions(authorization:WorkPackageAuthorization) {
    let actions:WorkPackageAction[] = authorization.permittedActionsWithLinks(PERMITTED_CONTEXT_MENU_ACTIONS);

    // Splice plugin actions onto the core actions
    _.each(this.getPermittedPluginActions(authorization), (action:WorkPackageAction) => {
      let index = action.indexBy ? action.indexBy(actions) : actions.length;
      actions.splice(index, 0, action);
    });

    return actions;
  }

  private getPermittedPluginActions(authorization:WorkPackageAuthorization) {
    let actions:WorkPackageAction[] = this.HookService.call('workPackageSingleContextMenu');
    return authorization.permittedActionsWithLinks(actions);
  }

  protected buildItems(permittedActions:WorkPackageAction[]):OpContextMenuItem[] {
    const configureFormLink = this.workPackage.configureForm;

    this.items = permittedActions.map((action:WorkPackageAction) => {
      const key = action.key;
      return {
        disabled: false,
        linkText: I18n.t('js.button_' + key),
        href: action.link,
        icon: action.icon || `icon-${key}`,
        onClick: ($event:JQueryEventObject) => {
          if (action.link && LinkHandling.isClickedWithModifier($event)) {
            return false;
          }

          this.triggerContextMenuAction(action, key);
          return true;
        }
      };
    });

    if (configureFormLink) {
      this.items.push(
        {
          href: configureFormLink.href,
          icon: 'icon-settings3',
          linkText: I18n.t('js.button_configure-form'),
          onClick: () => false
        }
      );
    }

    return this.items;
  }
}
