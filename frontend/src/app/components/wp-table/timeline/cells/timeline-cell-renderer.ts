import * as moment from 'moment';
import {WorkPackageResource} from 'core-app/modules/hal/resources/work-package-resource';
import {
  calculatePositionValueForDayCount,
  calculatePositionValueForDayCountingPx,
  calculatePositionValueForHourCount,
  RenderInfo,
  timelineElementCssClass,
  timelineMarkerSelectionStartClass
} from '../wp-timeline';
import {
  classNameFarRightLabel,
  classNameHideOnHover,
  classNameHoverStyle,
  classNameLeftHoverLabel,
  classNameLeftLabel,
  classNameRightContainer,
  classNameRightHoverLabel,
  classNameRightLabel,
  classNameShowOnHover,
  WorkPackageCellLabels
} from './wp-timeline-cell';
import {
  classNameBarLabel, classNameFactBar, classNameHistBar, classNameTrudozatraty,
  classNameLeftHandle,
  classNameRightHandle
} from './wp-timeline-cell-mouse-handler';
import {WorkPackageTimelineTableController} from '../container/wp-timeline-container.directive';
import {hasChildrenInTable} from '../../../wp-fast-table/helpers/wp-table-hierarchy-helpers';
import {WorkPackageChangeset} from '../../../wp-edit-form/work-package-changeset';
import {WorkPackageTableTimelineService} from '../../../wp-fast-table/state/wp-table-timeline.service';
import {DisplayFieldRenderer} from '../../../wp-edit-form/display-field-renderer';
import Moment = moment.Moment;
import {Injector} from '@angular/core';
import {TimezoneService} from 'core-components/datetime/timezone.service';
import {Highlighting} from "core-components/wp-fast-table/builders/highlighting/highlighting.functions";
import {TableState} from "core-components/wp-table/table-state/table-state";

export interface CellDateMovement {
  // Target values to move work package to
  startDate?:moment.Moment;
  dueDate?:moment.Moment;
  // Target value to move milestone to
  date?:moment.Moment;
}

export type LabelPosition = 'left' | 'right' | 'farRight';

export class TimelineCellRenderer {
  readonly timezoneService = this.injector.get(TimezoneService);
  readonly wpTableTimeline:WorkPackageTableTimelineService = this.injector.get(WorkPackageTableTimelineService);
  public fieldRenderer:DisplayFieldRenderer = new DisplayFieldRenderer(this.injector, 'timeline');

  protected dateDisplaysOnMouseMove:{ left?:HTMLElement; right?:HTMLElement } = {};

  constructor(readonly injector:Injector,
              readonly workPackageTimeline:WorkPackageTimelineTableController) {
  }

  public get type():string {
    return 'bar';
  }

  public get fallbackColor():string {
    return 'rgba(50, 50, 50, 0.1)';
  }

  public canMoveDates(wp:WorkPackageResource) {
    return wp.schema.startDate.writable && wp.schema.dueDate.writable && wp.isAttributeEditable('startDate');
  }

  public isEmpty(wp:WorkPackageResource) {
    const start = moment(wp.startDate as any);
    const due = moment(wp.dueDate as any);
    const noStartAndDueValues = _.isNaN(start.valueOf()) && _.isNaN(due.valueOf());
    return noStartAndDueValues;
  }

  public displayPlaceholderUnderCursor(ev:MouseEvent, renderInfo:RenderInfo):HTMLElement {
    const days = Math.floor(ev.offsetX / renderInfo.viewParams.pixelPerDay);

    const placeholder = document.createElement('div');
    placeholder.style.pointerEvents = 'none';
    placeholder.style.backgroundColor = '#DDDDDD';
    placeholder.style.position = 'absolute';
    placeholder.style.height = '1em';
    placeholder.style.width = '30px';
    placeholder.style.zIndex = '9999';
    placeholder.style.left = (days * renderInfo.viewParams.pixelPerDay) + 'px';

    return placeholder;
  }

  /**
   * Assign changed dates to the work package.
   * For generic work packages, assigns start and finish date.
   *
   */
  public assignDateValues(changeset:WorkPackageChangeset,
                          labels:WorkPackageCellLabels,
                          dates:any):void {

    this.assignDate(changeset, 'startDate', dates.startDate);
    this.assignDate(changeset, 'dueDate', dates.dueDate);
    //bbm(
    this.assignDate(changeset, 'factDueDate', dates.factDueDate);
    this.assignDate(changeset, 'firstDueDate', dates.firstDueDate);
    this.assignDate(changeset, 'lastDueDate', dates.lastDueDate);
    this.assignDate(changeset, 'firstStartDate', dates.firstStartDate);
    this.assignDate(changeset, 'lastStartDate', dates.lastStartDate);
    //)
    this.updateLabels(true, labels, changeset);
  }

  /**
   * Handle movement by <delta> days of the work package to either (or both) edge(s)
   * depending on which initial date was set.
   */
  public onDaysMoved(changeset:WorkPackageChangeset,
                     dayUnderCursor:Moment,
                     delta:number,
                     direction:'left' | 'right' | 'both' | 'create' | 'dragright'):CellDateMovement {

    const initialStartDate = changeset.workPackage.startDate;
    const initialDueDate = changeset.workPackage.dueDate;

    const startDate = moment(changeset.value('startDate'));
    const dueDate = moment(changeset.value('dueDate'));
    let dates:CellDateMovement = {};

    if (direction === 'left') {
      dates.startDate = moment(initialStartDate || initialDueDate).add(delta, 'days');
    } else if (direction === 'right') {
      dates.dueDate = moment(initialDueDate || initialStartDate).add(delta, 'days');
    } else if (direction === 'both') {
      if (initialStartDate) {
        dates.startDate = moment(initialStartDate).add(delta, 'days');
      }
      if (initialDueDate) {
        dates.dueDate = moment(initialDueDate).add(delta, 'days');
      }
    } else if (direction === 'dragright') {
      dates.dueDate = startDate.clone().add(delta, 'days');
    }

    // avoid negative "overdrag" if only start or due are changed
    if (direction !== 'both') {
      if (dates.startDate !== undefined && dates.startDate.isAfter(dueDate)) {
        dates.startDate = dueDate;
      } else if (dates.dueDate !== undefined && dates.dueDate.isBefore(startDate)) {
        dates.dueDate = startDate;
      }
    }

    return dates;
  }

  public onMouseDown(ev:MouseEvent,
                     dateForCreate:string | null,
                     renderInfo:RenderInfo,
                     labels:WorkPackageCellLabels,
                     elem:HTMLElement):'left' | 'right' | 'both' | 'dragright' | 'create' {

    // check for active selection mode
    if (renderInfo.viewParams.activeSelectionMode) {
      renderInfo.viewParams.activeSelectionMode(renderInfo.workPackage);
      ev.preventDefault();
      return 'both'; // irrelevant
    }

    const changeset = renderInfo.changeset;
    let direction:'left' | 'right' | 'both' | 'dragright';

    // Update the cursor and maybe set start/due values
    if (jQuery(ev.target!).hasClass(classNameLeftHandle)) {
      // only left
      direction = 'left';
      this.workPackageTimeline.forceCursor('col-resize');
      if (changeset.value('startDate') === null) {
        changeset.setValue('startDate', changeset.value('dueDate'));
      }
    } else if (jQuery(ev.target!).hasClass(classNameRightHandle) || dateForCreate) {
      // only right
      direction = 'right';
      this.workPackageTimeline.forceCursor('col-resize');
      if (changeset.value('dueDate') === null) {
        changeset.setValue('dueDate', changeset.value('startDate'));
      }
    } else {
      // both
      direction = 'both';
      this.workPackageTimeline.forceCursor('ew-resize');
    }

    if (dateForCreate) {
      changeset.setValue('startDate', dateForCreate);
      changeset.setValue('dueDate', dateForCreate);
      direction = 'dragright';
    }

    this.updateLabels(true, labels, renderInfo.changeset);

    return direction;
  }

  public onMouseDownEnd(labels:WorkPackageCellLabels, changeset:WorkPackageChangeset) {
    this.updateLabels(false, labels, changeset);
  }

  /**
   * @return true, if the element should still be displayed.
   *         false, if the element must be removed from the timeline.
   */
  public update(bar:HTMLDivElement, labels:WorkPackageCellLabels|null, renderInfo:RenderInfo):boolean {
    const changeset = renderInfo.changeset;

    const viewParams = renderInfo.viewParams;
    let start = moment(changeset.value('startDate'));
    let due = moment(changeset.value('dueDate'));

    if (_.isNaN(start.valueOf()) && _.isNaN(due.valueOf())) {
      bar.style.visibility = 'hidden';
    } else {
      bar.style.visibility = 'visible';
    }

    // only start date, fade out bar to the right
    if (_.isNaN(due.valueOf()) && !_.isNaN(start.valueOf())) {
      // Set due date to today
      due = moment();
      bar.style.backgroundImage = `linear-gradient(90deg, rgba(255,255,255,0) 0%, #F1F1F1 100%)`;
    }

    // only finish date, fade out bar to the left
    if (_.isNaN(start.valueOf()) && !_.isNaN(due.valueOf())) {
      start = due.clone();
      bar.style.backgroundImage = `linear-gradient(90deg, #F1F1F1 0%, rgba(255,255,255,0) 80%)`;
    }

    // offset left
    const offsetStart = start.diff(viewParams.dateDisplayStart, 'days');
    bar.style.left = calculatePositionValueForDayCount(viewParams, offsetStart);

    // duration
    const duration = due.diff(start, 'days') + 1;
    bar.style.width = calculatePositionValueForDayCount(viewParams, duration);

    // ensure minimum width
    if (!_.isNaN(start.valueOf()) || !_.isNaN(due.valueOf())) {
      const minWidth = _.max([renderInfo.viewParams.pixelPerDay, 2]);
      bar.style.minWidth = minWidth + 'px';
    }

    // Update labels if any
    if (labels) {
      this.updateLabels(false, labels, changeset);
    }

    this.checkForActiveSelectionMode(renderInfo, bar);
    this.checkForSpecialDisplaySituations(renderInfo, bar);

    //bbm(
    let fact = moment(renderInfo.workPackage.factDueDate);
    if (!_.isNaN(fact.valueOf())) {
      let factBar = _.find(bar.childNodes, (child:any) => {
        return child.className === 'factBar';
      });
      let factWidth = fact.diff(due, 'days');
      if (factWidth > 0) {
        let containerRight = _.find(bar.childNodes, (child:any) => {return child.className === 'containerRight'; });
        if (containerRight) {
          containerRight.style.paddingLeft = calculatePositionValueForDayCount(viewParams, factWidth);
        }
        if (factBar) {
          factBar.style.left = calculatePositionValueForDayCount(viewParams, duration);
          factBar.style.width = calculatePositionValueForDayCount(viewParams, factWidth);
        }
      } else {
        if (factBar) {
          factBar.style.left = calculatePositionValueForDayCount(viewParams, duration + factWidth);
          factBar.style.width = calculatePositionValueForDayCount(viewParams, 0 - factWidth);
        }
      }
    }
    if (renderInfo.viewParams.settings.firstOrLastHistDate !== 0) {
      let histStart = renderInfo.viewParams.settings.firstOrLastHistDate === 1 ? moment(renderInfo.workPackage.firstStartDate) : moment(renderInfo.workPackage.lastStartDate);
      let histDue = renderInfo.viewParams.settings.firstOrLastHistDate === 1 ? moment(renderInfo.workPackage.firstDueDate) : moment(renderInfo.workPackage.lastDueDate);
      if (!_.isNaN(histStart.valueOf()) && !_.isNaN(histDue.valueOf())) {
        let histBar = _.find(bar.childNodes, (child:any) => {
          return child.classList.contains('histBar') === true;
        });
        const offsetHistStart = offsetStart === 0 ? histStart.diff(viewParams.dateDisplayStart, 'days') : histStart.diff(start, 'days');
        const histWidth = histDue.diff(histStart, 'days') + 1;
        if (histBar) {
          histBar.style.left = calculatePositionValueForDayCount(viewParams, offsetHistStart);
          histBar.style.width = calculatePositionValueForDayCount(viewParams, histWidth);
          let status = renderInfo.workPackage.status;
          if (!status) {
            histBar.style.borderColor = 'black';
          }
          const id = status.getId();
          const today = moment().startOf('day');
          const overdueOrNot = histDue.diff(today, 'days');
          if (overdueOrNot <= -1) {
            histBar.classList.add('__hl_border_overdue');
          } else {
            histBar.classList.add(Highlighting.borderClass('status', id));
          }
        }
      }
    }

    if (renderInfo.viewParams.settings.trudozatraty) {
      //ababab
      let trudozatraty = _.find(bar.childNodes, (child:any) => {
        return child.classList.contains('trudozatraty') === true;
      });
      if (trudozatraty) {
        let timeEntriesSum = renderInfo.workPackage.timeEntriesSum;
        trudozatraty.style.width = calculatePositionValueForHourCount(viewParams, timeEntriesSum);
        let status = renderInfo.workPackage.status;
        if (!status) {
          trudozatraty.style.backgroundColor = 'black';
        }
        const id = status.getId();
        if (timeEntriesSum >= duration * 8) {
          trudozatraty.classList.add('__hl_row_overdue');
        } else {
          trudozatraty.classList.add(Highlighting.rowClass('status', id));
          trudozatraty.classList.add('__hl_border_overdue');
        }
      }
    }
    //)
    return true;
  }

  protected checkForActiveSelectionMode(renderInfo:RenderInfo, element:HTMLElement) {
    if (renderInfo.viewParams.activeSelectionMode) {
      element.style.backgroundImage = null; // required! unable to disable "fade out bar" with css

      if (renderInfo.viewParams.selectionModeStart === '' + renderInfo.workPackage.id) {
        jQuery(element).addClass(timelineMarkerSelectionStartClass);
        element.style.background = null;
      }
    }
  }

  getMarginLeftOfLeftSide(renderInfo:RenderInfo):number {
    const changeset = renderInfo.changeset;

    let start = moment(changeset.value('startDate'));
    let due = moment(changeset.value('dueDate'));
    start = _.isNaN(start.valueOf()) ? due.clone() : start;

    const offsetStart = start.diff(renderInfo.viewParams.dateDisplayStart, 'days');

    return calculatePositionValueForDayCountingPx(renderInfo.viewParams, offsetStart);
  }

  getMarginLeftOfRightSide(renderInfo:RenderInfo):number {
    const changeset = renderInfo.changeset;

    let start = moment(changeset.value('startDate'));
    let due = moment(changeset.value('dueDate'));

    start = _.isNaN(start.valueOf()) ? due.clone() : start;
    due = _.isNaN(due.valueOf()) ? start.clone() : due;

    const offsetStart = start.diff(renderInfo.viewParams.dateDisplayStart, 'days');
    const duration = due.diff(start, 'days') + 1;

    return calculatePositionValueForDayCountingPx(renderInfo.viewParams, offsetStart + duration);
  }

  getPaddingLeftForIncomingRelationLines(renderInfo:RenderInfo):number {
    return renderInfo.viewParams.pixelPerDay / 8;
  }

  getPaddingRightForOutgoingRelationLines(renderInfo:RenderInfo):number {
    return 0;
  }

  /**
   * Render the generic cell element, a bar spanning from
   * start to finish date.
   */
  public render(renderInfo:RenderInfo):HTMLDivElement {
    const bar = document.createElement('div');
    const left = document.createElement('div');
    const right = document.createElement('div');

    bar.className = timelineElementCssClass + ' ' + this.type;
    left.className = classNameLeftHandle;
    right.className = classNameRightHandle;
    bar.appendChild(left);
    bar.appendChild(right);
    //bbm(
    if (renderInfo.workPackage.factDueDate) {
      const fact = document.createElement('div');
      fact.className = classNameFactBar;
      bar.appendChild(fact);
    }
    if (renderInfo.viewParams.settings.firstOrLastHistDate !== 0) {
      let histStart = renderInfo.viewParams.settings.firstOrLastHistDate === 1 ? renderInfo.workPackage.firstStartDate : renderInfo.workPackage.lastStartDate;
      let histDue = renderInfo.viewParams.settings.firstOrLastHistDate === 1 ? renderInfo.workPackage.firstDueDate : renderInfo.workPackage.lastDueDate;
      if (histStart && histDue) {
        const hist = document.createElement('div');
        hist.className = classNameHistBar;
        bar.appendChild(hist);
      }
    }
    if (this.wpTableTimeline.getTrudozatraty() && renderInfo.workPackage.timeEntriesSum > 0) {
        const trudozatraty = document.createElement('div');
        trudozatraty.className = classNameTrudozatraty;
        /*if (attribute === 'subject') {
          span.textContent += ' Трудовые затраты: ' + changeset.workPackage.timeEntriesSum + 'ч.';
        }*/
        bar.appendChild(trudozatraty);
    }
    //)
    return bar;
  }

  createAndAddLabels(renderInfo:RenderInfo, element:HTMLElement):WorkPackageCellLabels {
    // create center label
    const labelCenter = document.createElement('div');
    labelCenter.classList.add(classNameBarLabel);
    this.applyTypeColor(renderInfo.workPackage, labelCenter);
    element.appendChild(labelCenter);

    // create left label
    const labelLeft = document.createElement('div');
    labelLeft.classList.add(classNameLeftLabel, classNameHideOnHover);
    element.appendChild(labelLeft);

    // create right container
    const containerRight = document.createElement('div');
    containerRight.classList.add(classNameRightContainer);
    element.appendChild(containerRight);

    // create right label
    const labelRight = document.createElement('div');
    labelRight.classList.add(classNameRightLabel, classNameHideOnHover);
    containerRight.appendChild(labelRight);

    // create far right label
    const labelFarRight = document.createElement('div');
    labelFarRight.classList.add(classNameFarRightLabel, classNameHideOnHover);
    containerRight.appendChild(labelFarRight);

    // create left hover label
    const labelHoverLeft = document.createElement('div');
    labelHoverLeft.classList.add(classNameLeftHoverLabel  , classNameShowOnHover, classNameHoverStyle);
    element.appendChild(labelHoverLeft);

    // create right hover label
    const labelHoverRight = document.createElement('div');
    labelHoverRight.classList.add(classNameRightHoverLabel, classNameShowOnHover, classNameHoverStyle);
    element.appendChild(labelHoverRight);

    const labels = new WorkPackageCellLabels(labelCenter, labelLeft, labelHoverLeft, labelRight, labelHoverRight, labelFarRight);
    this.updateLabels(false, labels, renderInfo.changeset);

    return labels;
  }

  protected applyTypeColor(wp:WorkPackageResource, element:HTMLElement):void {
    const diff = this.timezoneService.daysFromToday(wp.dueDate);
    if (diff <= -1) {
      element.classList.add('__hl_row_overdue');
    } else {
      let status = wp.status;
      if (!status) {
        element.style.backgroundColor = this.fallbackColor;
      }
      const id = status.getId();
      element.classList.add(Highlighting.rowClass('status', id));
    }
    //bbm( Старый вариант по типу мероприятия
    /*if (renderInfo.viewParams.settings.firstOrLastHistDate) {
      let type = wp.type;
      if (!type) {
        element.style.backgroundColor = this.fallbackColor;
      }
      if (wp.isClosed) {
        element.style.backgroundColor = 'rgba(255, 165, 0, 1)'; //orange
      } else {
        const id = type.getId();
        element.classList.add(Highlighting.rowClass('type', id));
      }
    } else {*/
    //)
  }

  protected assignDate(changeset:WorkPackageChangeset, attributeName:string, value:moment.Moment) {
    if (value) {
      changeset.setValue(attributeName, value.format('YYYY-MM-DD'));
    }
  }

  /**
   * Changes the presentation of the work package.
   *
   * Known cases:
   * 1. Display a clamp if this work package is a parent element
   */
  checkForSpecialDisplaySituations(renderInfo:RenderInfo, bar:HTMLElement) {
    const wp = renderInfo.workPackage;

    // Cannot eddit the work package if it has children
    if (!wp.isLeaf) {
      bar.classList.add('-readonly');
    }

    // Display the parent as clamp-style when it has children in the table
    if (this.workPackageTimeline.inHierarchyMode &&
      hasChildrenInTable(wp, this.workPackageTimeline.workPackageTable)) {
      // this.applyTypeColor(wp, bar);
      bar.classList.add('-clamp-style');
      bar.style.borderStyle = 'solid';
      bar.style.borderWidth = '2px';
      bar.style.borderBottom = 'none';
      bar.style.background = 'none';
    } else {
      // Apply the background color
      this.applyTypeColor(renderInfo.workPackage, bar);
    }
  }

  protected updateLabels(activeDragNDrop:boolean,
                         labels:WorkPackageCellLabels,
                         changeset:WorkPackageChangeset) {

    const labelConfiguration = this.wpTableTimeline.getNormalizedLabels(changeset.workPackage);

    if (!activeDragNDrop) {
      // normal display
      this.renderLabel(changeset, labels, 'left', labelConfiguration.left);
      this.renderLabel(changeset, labels, 'right', labelConfiguration.right);
      this.renderLabel(changeset, labels, 'farRight', labelConfiguration.farRight);
    }

    // Update hover labels
    this.renderHoverLabels(labels, changeset);
  }

  protected renderHoverLabels(labels:WorkPackageCellLabels, changeset:WorkPackageChangeset) {
    this.renderLabel(changeset, labels, 'leftHover', 'startDate');
    this.renderLabel(changeset, labels, 'rightHover', 'dueDate');
  }

  protected renderLabel(changeset:WorkPackageChangeset,
                        labels:WorkPackageCellLabels,
                        position:LabelPosition|'leftHover'|'rightHover',
                        attribute:string|null) {

    // Get the label position
    // Skip label if it does not exist (milestones)
    let label = labels[position];
    if (!label) {
      return;
    }

    // Reset label value
    label.innerHTML = '';

    if (attribute === null) {
      label.classList.remove('not-empty');
      return;
    }

    // Get the rendered field
    let [field, span] = this.fieldRenderer.renderFieldValue(changeset.workPackage, attribute, changeset);
    //bbm(
    if (this.wpTableTimeline.getTrudozatraty()) {
      if (attribute === 'subject') {
        span.textContent += ' Трудовые затраты: ' + changeset.workPackage.timeEntriesSum + 'ч.';
      }
    }
    let [fieldFact, spanFact] = attribute === 'dueDate' ? this.fieldRenderer.renderFieldValue(changeset.workPackage, 'factDueDate', changeset) : [null, span];
    //)

    if (label && field && span) {
      span.classList.add('label-content');
      label.appendChild(span);
      //bbm(
      if (spanFact.textContent !== '-' && attribute === 'dueDate') {
        let spanLeft = document.createElement('span');
        spanLeft.textContent = '(Фактически: ';
        label.appendChild(spanLeft);
        label.appendChild(spanFact);
        let spanRight = document.createElement('span');
        spanRight.textContent = ')';
        label.appendChild(spanRight);
      }
      //)
      label.classList.add('not-empty');
    } else if (label) {
      label.classList.remove('not-empty');
    }
  }
}
