//-- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

import {Component, ElementRef} from '@angular/core';
import {PathHelperService} from 'core-app/modules/common/path-helper/path-helper.service';
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';
import {WorkPackageResource} from 'core-app/modules/hal/resources/work-package-resource';
import {CollectionResource} from 'core-app/modules/hal/resources/collection-resource';
import {HalResourceService} from 'core-app/modules/hal/services/hal-resource.service';
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {WpTopicsConfigurationModalComponent} from "core-components/wp-topics-dialog/wp-topics-configuration.modal";
import {OpModalService} from "core-components/op-modals/op-modal.service";

export const wpTopicsAutocompleteUpgraded = 'wp-topics-autocomplete-upgraded';

@Component({
  selector: wpTopicsAutocompleteUpgraded,
  templateUrl: './wp-topics-autocomplete.upgraded.html'
})
export class WpTopicsAutocompleteComponent {
  public selectedWP:string = '';
  public selectedWPid:string;
  private projectId:string;
  constructor(readonly pathHelper:PathHelperService,
              readonly element:ElementRef,
              protected halResourceService:HalResourceService,
              readonly I18n:I18nService,
              //bbm(
              readonly opModalService:OpModalService) {
    // )
  }

  ngOnInit() {
    if (this.element.nativeElement.getAttribute('projectObject')) {
      this.projectId = JSON.parse(this.element.nativeElement.getAttribute('projectObject'));
    }
    if (this.element.nativeElement.getAttribute('wpId')) {
      this.selectedWPid = JSON.parse(this.element.nativeElement.getAttribute('wpId'));
      this.halResourceService
        .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.wpBySubjectOrId(this.selectedWPid, true).toString())
        .toPromise()
        .then((wps:CollectionResource<WorkPackageResource>) => {
          if (wps.count > 0) {
            this.selectedWP = wps.elements[0].subject || '';
          }
        });
    }
  }

  //bbm(
  openDialog():void {
    const modal = this.opModalService.show<WpTopicsConfigurationModalComponent>(WpTopicsConfigurationModalComponent, {projectId: this.projectId});
    modal.closingEvent.subscribe((modal:WpTopicsConfigurationModalComponent) => {
      if (modal.selectedWp) {
        /*this.$element = jQuery(this.element.nativeElement);
        const input = this.$input = this.$element.find('.wp-relations--autocomplete');
        input.val(this.getIdentifier(modal.selectedWp));
        this.onSelect.emit(modal.selectedWp.id);*/

        this.selectedWP = modal.selectedWp.subject;
        this.selectedWPid = modal.selectedWp.id;
      }
    });
  }
  //)
}

DynamicBootstrapper.register({ selector: wpTopicsAutocompleteUpgraded, cls: WpTopicsAutocompleteComponent });
