// -- copyright
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
// ++

import {Injector} from '@angular/core';
import {States} from '../../../states.service';
import {WorkPackageChangeset} from '../../../wp-edit-form/work-package-changeset';
import {RenderedRow} from '../../../wp-fast-table/builders/primary-render-pass';
import {WorkPackageTimelineTableController} from '../container/wp-timeline-container.directive';
import {RenderInfo} from '../wp-timeline';
import {TimelineCellRenderer} from './timeline-cell-renderer';
import {TimelineMilestoneCellRenderer} from './timeline-milestone-cell-renderer';
import {WorkPackageTimelineCell} from './wp-timeline-cell';
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";

export class WorkPackageTimelineCellsRenderer {

  // Injections
  public states = this.injector.get(States);

  public cells:{ [classIdentifier:string]:WorkPackageTimelineCell } = {};

  private cellRenderers:{ milestone:TimelineMilestoneCellRenderer, generic:TimelineCellRenderer };

  constructor(public readonly injector:Injector, private wpTimeline:WorkPackageTimelineTableController) {
    this.cellRenderers = {
      milestone: new TimelineMilestoneCellRenderer(this.injector, wpTimeline),
      generic: new TimelineCellRenderer(this.injector, wpTimeline)
    };
  }

  public hasCell(wpId:string) {
    return this.getCellsFor(wpId).length > 0;
  }

  public getCellsFor(wpId:string):WorkPackageTimelineCell[] {
    return _.filter(this.cells, (cell) => cell.workPackageId === wpId) || [];
  }

  /**
   * Synchronize the currently active cells and render them all
   */
  public refreshAllCells() {
    // Create new cells and delete old ones
    this.synchronizeCells();

    // Update all cells
    _.each(this.cells, (cell) => this.refreshSingleCell(cell));
  }

  public refreshCellsFor(wpId:string) {
    _.each(this.getCellsFor(wpId), (cell) => this.refreshSingleCell(cell));
  }

  public refreshSingleCell(cell:WorkPackageTimelineCell) {
    const renderInfo = cell.classIdentifier.slice(-4) === 'fact' ? this.renderInfoForFact(cell.workPackageId) : this.renderInfoFor(cell.workPackageId);

    if (renderInfo && renderInfo.workPackage) {
      cell.refreshView(renderInfo);
    }
  }

  /**
   * Synchronize the current cells:
   *
   * 1. Create new cells in workPackageIdOrder not yet tracked
   * 2. Remove old cells no longer contained.
   */
  private synchronizeCells() {
    const currentlyActive:string[] = Object.keys(this.cells);
    const newCells:string[] = [];

    _.each(this.wpTimeline.workPackageIdOrder, (renderedRow:RenderedRow) => {
      const wpId = renderedRow.workPackageId;

      // Ignore extra rows not tied to a work package
      if (!wpId) {
        return;
      }

      const state = this.states.workPackages.get(wpId);
      if (state.isPristine()) {
        return;
      }

      // As work packages may occur several times, get the unique identifier
      // to identify the cell
      const identifier = renderedRow.classIdentifier;

      // Create a cell unless we already have an active cell
      if (!this.cells[identifier]) {
        this.cells[identifier] = this.buildCell(identifier, wpId.toString());
      }

      newCells.push(identifier);

      //bbm(
      // Пытаюсь добавить другой cell рядом с текущим
      //const identifierFact = renderedRow.classIdentifier.slice(0, 7) + '0' + renderedRow.classIdentifier.slice(8);
      const identifierFact = renderedRow.classIdentifier + '-fact';
      // Create a cell unless we already have an active cell
      if (!this.cells[identifierFact]) {
        const factCell = this.buildCellFact(identifierFact, wpId.toString());
        if (factCell) {
          this.cells[identifierFact] = factCell;
        }
      }
      newCells.push(identifierFact);
      //)
    });

    _.difference(currentlyActive, newCells).forEach((identifier:string) => {
      this.cells[identifier].clear();
      delete this.cells[identifier];
    });
  }

  private buildCell(classIdentifier:string, workPackageId:string) {
    return new WorkPackageTimelineCell(
      this.injector,
      this.wpTimeline,
      this.cellRenderers,
      this.renderInfoFor(workPackageId),
      classIdentifier,
      workPackageId
    );
  }

  private renderInfoFor(wpId:string):RenderInfo {
    const wp = this.states.workPackages.get(wpId).value!;
    return {
      viewParams: this.wpTimeline.viewParameters,
      workPackage: wp,
      changeset: new WorkPackageChangeset(this.injector, wp)
    } as RenderInfo;
  }
  //bbm(
  //попытка добавить факт cell в timeline
  private buildCellFact(classIdentifier:string, workPackageId:string) {
    const renderInfo = this.renderInfoForFact(workPackageId);
    if (renderInfo) {
      return new WorkPackageTimelineCell(
        this.injector,
        this.wpTimeline,
        this.cellRenderers,
        renderInfo,
        classIdentifier,
        workPackageId
      );
    } else {
      return null;
    }
  }

  private renderInfoForFact(wpId:string):RenderInfo | null {
    const wp = this.states.workPackages.get(wpId).value!;
    if (wp.factDueDate) {
      let wpClone:WorkPackageResource = Object.assign({}, wp);
      let startDate = new Date(wpClone.dueDate + 'Z00:00:00:000');
      let dueDate = new Date(wpClone.factDueDate + 'Z00:00:00:000');
      if (startDate > dueDate) {
        let tmp = startDate;
        startDate = dueDate;
        dueDate = tmp;
      }
      wpClone.startDate = startDate.toISOString().slice(0, 10);
      wpClone.dueDate = dueDate.toISOString().slice(0, 10);
      return {
        viewParams: this.wpTimeline.viewParameters,
        workPackage: wpClone,
        changeset: new WorkPackageChangeset(this.injector, wpClone)
      } as RenderInfo;
    } else {
      return null;
    }
  }
  //)
}
