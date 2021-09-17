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

import {Directive, ElementRef, Input} from '@angular/core';
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';

import {OpContextMenuTrigger} from 'core-components/op-context-menu/handlers/op-context-menu-trigger.directive';
import {OPContextMenuService} from 'core-components/op-context-menu/op-context-menu.service';
import {OpContextMenuItem} from 'core-components/op-context-menu/op-context-menu.types';
import {OpModalService} from 'core-components/op-modals/op-modal.service';
import {WorkPackageTableColumnsService} from 'core-components/wp-fast-table/state/wp-table-columns.service';
import {WorkPackageTableGroupByService} from 'core-components/wp-fast-table/state/wp-table-group-by.service';
import {WorkPackageTableHierarchiesService} from 'core-components/wp-fast-table/state/wp-table-hierarchy.service';
import {WorkPackageTableSortByService} from 'core-components/wp-fast-table/state/wp-table-sort-by.service';
import {WorkPackageTable} from 'core-components/wp-fast-table/wp-fast-table';
import {QueryColumn} from 'core-components/wp-query/query-column';
import {WpTableConfigurationModalComponent} from 'core-components/wp-table/configuration-modal/wp-table-configuration.modal';

@Directive({
  selector: '[projectsTableContextMenu]'
})
export class ProjectsTableContextMenuDirective extends OpContextMenuTrigger {
  // @Input('projectsTableContextMenu-columns') public column:QueryColumn;
  // @Input('projectsTableContextMenu-table') public table:WorkPackageTable;
  @Input('projectsTableContextMenu-identifier') public identifier: string;

  constructor(readonly elementRef:ElementRef,
              readonly opContextMenu:OPContextMenuService,
              readonly I18n:I18nService) {

    super(elementRef, opContextMenu);
  }

  protected open(evt:JQueryEventObject) {
    this.buildItems();
    console.dir({ context: this.items });
    this.opContextMenu.show(this, evt);
  }

  public get locals() {
    return {
      showAnchorRight: !!this.identifier,
      contextMenuId: 'column-context-menu',
      items: this.items
    };
  }

  /**
   * Positioning args for jquery-ui position.
   *
   * @param {Event} openerEvent
   */
  public positionArgs(evt:JQueryEventObject) {
    let additionalPositionArgs = {
      of:  this.$element.find('.generic-table--sort-header-outer'),
    };

    let position = super.positionArgs(evt);
    _.assign(position, additionalPositionArgs);

    return position;
  }

  protected get afterFocusOn():JQuery {
    return this.$element.find(`#${this.identifier}`);
  }

  private buildItems() {
    this.items = [
      {
        //label_subproject_new
        linkText: 'Новый подпроект',
        icon: 'icon-add',
        href: `/projects/new?parent_id=${ this.identifier }`,
        onClick: () => {
          return true;
        }
      },
      {
        linkText: 'Настройки проекта',
        icon: 'icon-settings',
        href: `/projects/${ this.identifier }/settings`,
        onClick: () => {
          return true;
        }
      },
      {
        linkText: 'Архив',
        icon: 'icon-locked',
        href: `/projects/${ this.identifier }/archive`,
        onClick: () => {
          return true;
        }
      },
      {
        linkText: 'Копировать',
        icon: 'icon-copy',
        href: `/projects/${ this.identifier }/copy_project_from_admin`,
        onClick: () => {
          return true;
        }
      },
      {
        linkText: 'Удалить',
        icon: 'icon-delete',
        href: `/projects/${ this.identifier }/destroy_info`,
        onClick: () => {
          return true;
        }
      }
    ];
  }
}

