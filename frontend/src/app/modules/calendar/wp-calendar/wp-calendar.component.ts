import {Component, ElementRef, Input, OnDestroy, OnInit, ViewChild, SecurityContext} from "@angular/core";
import {CalendarComponent} from 'ng-fullcalendar';
import {Options} from 'fullcalendar';
import {States} from "core-components/states.service";
import {TableState} from "core-components/wp-table/table-state/table-state";
import {untilComponentDestroyed} from "ng2-rx-componentdestroyed";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {WorkPackageCollectionResource} from "core-app/modules/hal/resources/wp-collection-resource";
import {WorkPackageTableFiltersService} from "core-components/wp-fast-table/state/wp-table-filters.service";
import {Moment} from "moment";
import {WorkPackagesListService} from "core-components/wp-list/wp-list.service";
import {StateService} from "@uirouter/core";
import {UrlParamsHelperService} from "core-components/wp-query/url-params-helper";
import * as moment from "moment";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {DomSanitizer} from "@angular/platform-browser";
import {WorkPackagesListChecksumService} from "core-components/wp-list/wp-list-checksum.service";
import {OpTitleService} from "core-components/html/op-title.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
//import {BlueTableProtocolService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-protocol.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {OpModalService} from "core-components/op-modals/op-modal.service";
import {ChooseUserTaskModalComponent} from "core-app/modules/calendar/wp-calendar-dialogs/wp-calendar-choose-usertask.modal.component";
import {WpRelationsConfigurationModalComponent} from "core-components/wp-relations/wp-relations-create/wp-relations-dialog/wp-relations-configuration.modal";
import {ConfirmDialogModal} from "core-components/modals/confirm-dialog/confirm-dialog.modal";
import {start} from "repl";


@Component({
  templateUrl: './wp-calendar.template.html',
  selector: 'wp-calendar',
})
export class WorkPackagesCalendarController implements OnInit, OnDestroy {
  calendarOptions:Options;
  @ViewChild(CalendarComponent) ucCalendar:CalendarComponent;
  @Input() projectIdentifier:string;
  @Input() static:boolean = false;
  @Input() day:boolean = false;
  static MAX_DISPLAYED = 100;

  private workPackageGlobal: any;

  public workPackagesCalendarControllerInstance: WorkPackagesCalendarController;

  constructor(readonly states:States,
              readonly $state:StateService,
              readonly wpTableFilters:WorkPackageTableFiltersService,
              readonly wpListService:WorkPackagesListService,
              readonly wpListChecksumService:WorkPackagesListChecksumService,
              readonly tableState:TableState,
              readonly titleService:OpTitleService,
              readonly urlParamsHelper:UrlParamsHelperService,
              private element:ElementRef,
              readonly i18n:I18nService,
              readonly notificationsService:NotificationsService,
              private sanitizer:DomSanitizer,
    //          private protocolService: BlueTableProtocolService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              private readonly opModalService:OpModalService
  ) { }

  ngOnInit() {
    // Clear any old subscribers
    this.tableState.stopAllSubscriptions.next();

    this.setCalendarOptions();

    this.workPackagesCalendarControllerInstance = this;
  }

  ngOnDestroy() {
    // nothing to do
  }

  public onCalendarInitialized() {
    this.setupWorkPackagesListener();
  }

  public updateTimeframe($event:any) {
    let calendarView = this.calendarElement.fullCalendar('getView')!;
    let startDate = (calendarView.start as Moment).format('YYYY-MM-DD');
    let endDate = (calendarView.end as Moment).format('YYYY-MM-DD');

    if (!this.wpTableFilters.currentState && this.tableState.query.value) {
      // nothing to do
    } else if (!this.wpTableFilters.currentState) {
      let queryProps = this.defaultQueryProps(startDate, endDate);

      if (this.$state.params.query_props) {
        queryProps = decodeURIComponent(this.$state.params.query_props || '');
      }

      this.wpListService.fromQueryParams({ query_props: queryProps }, this.projectIdentifier).toPromise();
    } else {
      let params = this.$state.params;
      let filtersState = this.wpTableFilters.currentState;

      let datesIntervalFilter = _.find(filtersState.current, {'id': 'datesInterval'}) as any;

      datesIntervalFilter.values[0] = startDate;
      datesIntervalFilter.values[1] = endDate;

      this.wpTableFilters.replace(filtersState);
    }
  }

  public addTooltip($event:any) {
    let event = $event.detail.event;
    let element = $event.detail.element;

    let contentStr;

    switch (event.type_event) {
      case 'meeting':
        contentStr =  this.contentStringMeeting(event.meeting);
        break;
      case 'user_task':
        contentStr = this.contentStringUserTask(event.user_task);
        break;
      default:
        contentStr = this.contentString(event.workPackage);
    }

    jQuery(element).tooltip({
      content: contentStr,
      items: '.fc-content',
      track: true
    });
  }

  public toWPFullView($event:any) {
//    let workPackage = $event.detail.event.workPackage;

    // do not display the tooltip on the wp show page
    this.removeTooltip($event.detail.jsEvent.currentTarget);

    // Ensure checksum is removed to allow queries to load
    this.wpListChecksumService.clear();

    // Ensure current calendar URL is pushed to history
    window.history.pushState({}, this.titleService.current, window.location.href);


    switch ($event.detail.event.type_event) {
      case 'meeting': {
        let meeting = $event.detail.event.meeting;
        window.location.href = this.pathHelper.appBasePath + '/meetings/' + meeting.id;
        break;
      }
      case 'user_task': {
        let user_task = $event.detail.event.user_task;
        window.location.href = this.pathHelper.appBasePath + '/user_tasks/' + user_task.id;
        break;
      }
      default: {
        let workPackage = $event.detail.event.workPackage;
        this.$state.go(
          'work-packages.show',
          {workPackageId: workPackage.id},
          {inherit: false});
      }
    }
  }

  public onSelectDay($event: any) {
    this.addUserTask();
  }

  public setCustomPeriod() {
    //me.openDialog();
  }

  public openDialog() {
    const modal = this.opModalService.show<ChooseUserTaskModalComponent>(ChooseUserTaskModalComponent);

    modal.closingEvent.subscribe((modal:ChooseUserTaskModalComponent) => {
      if (modal.confirmed) {
        this.calendarElement.fullCalendar('changeView', 'basic', {
          start: modal.startPeriodDate,
          end: modal.endPeriodDate
        });

      //  this.calendarElement.fullCalendar('option', {
      //    start: modal.startPeriodDate,
      //    end: modal.endPeriodDate
      //  });
        modal.confirmed = false;
      }
    });
  }

  private get calendarElement() {
    return jQuery(this.element.nativeElement).find('ng-fullcalendar');
  }

  private setCalendarsDate() {
    const query = this.tableState.query.value;
    if (!query) {
      return;
    }

    let datesIntervalFilter = _.find(query.filters || [], {'id': 'datesInterval'}) as any;

    let calendarDate:any = null;
    let calendarUnit = 'month';
    if (this.day) {
      calendarUnit = 'agendaDay';
    }

    if (datesIntervalFilter) {
      let lower = moment(datesIntervalFilter.values[0] as string);
      let upper = moment(datesIntervalFilter.values[1] as string);
      let diff = upper.diff(lower, 'days');

      calendarDate = lower.add(diff / 2, 'days');

      if (diff === 7) {
        calendarUnit = 'basicWeek';
      }
    }

    if (calendarDate) {
      this.calendarElement.fullCalendar('changeView', calendarUnit, calendarDate);
    } else {
      this.calendarElement.fullCalendar('changeView', calendarUnit);
    }
  }

  private setupWorkPackagesListener() {
    this.tableState.results.values$().pipe(
      untilComponentDestroyed(this)
    ).subscribe((collection: WorkPackageCollectionResource) => {
      this.warnOnTooManyResults(collection);
      this.mapToCalendarEvents(collection.elements);
     // this.setCalendarsDate();
      this.getMeetingEvents();
      this.getUserTasks();
    });
  }

  private getMeetingEvents() {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.meetings.toString(), {project_identifier: this.projectIdentifier}).toPromise().then(

      (resources: CollectionResource<HalResource>) => {

        let events = resources.elements.map((meeting: HalResource) => {

          return {
            title: meeting.title,
            start: meeting.startTime,
          //  end: meeting.startTime,
            className: `__hl_row_type_${meeting.workPackageId}`,
            // workPackage: meeting.workPackage,
            meeting: meeting,
            type_event: "meeting"
          }

        });

        let oldEvent = this.ucCalendar.clientEvents(null);

        events = oldEvent.concat (events);

        this.ucCalendar.renderEvents(events);
      });
  }

  private getUserTasks() {
    this.halResourceService
     // .get<CollectionResource<HalResource>>(`${this.pathHelper.api.v3.apiV3Base}/user_tasks`, {project_identifier: this.projectIdentifier}).toPromise().then(
      .get<CollectionResource<HalResource>>(`${this.pathHelper.api.v3.apiV3Base}/user_tasks`).toPromise().then(

      (resources: CollectionResource<HalResource>) => {

        if (resources) {

          let events = resources.source.map((userTask: HalResource) => {
          //let events = resources.elements.map((user_task: HalResource) => {

            let kind = userTask.kind;
            switch (userTask.kind) {
              case 'Task':
                kind = "Задача";
                break;
              case 'Request':
                kind = "Запрос";
                break;
              case 'Note':
                kind = "Заметка";
                break;
              case 'Response':
                kind = "Ответ";
                break;
            }

            let titleUt = kind + ": " + userTask.text

            //if (Date.parse(userTask.due_date) < Date.now() && userTask.completed == 'Нет') {
              //titleUt = "(!) " + kind + ": " + userTask.text
            //}

            return {
              //title: userTask.kind == "Task" ? "Задача: " : "Заметка: " + userTask.text,
              title: titleUt,
              start: userTask.due_date,
              end: userTask.due_date,
              // className: `__hl_row_type_${meeting.workPackageId}`,
              // workPackage: meeting.workPackage,
              user_task: userTask,
              type_event: "user_task",
              color: (Date.parse(userTask.due_date) < Date.now() && userTask.completed == 'Нет' && ((userTask.kind == 'Task') || (userTask.kind == 'Request'))) ? "darkred" : ""
            }

          });

          let oldEvent = this.ucCalendar.clientEvents(null);

          events = oldEvent.concat(events);

          this.ucCalendar.renderEvents(events);
        }
      });
  }

  private mapToCalendarEvents(workPackages:WorkPackageResource[]) {

    let events = workPackages.map((workPackage:WorkPackageResource) => {
      let startDate = this.eventDate(workPackage, 'start');
      let endDate = this.eventDate(workPackage, 'due');

       return {
        title: workPackage.subject,
        start: startDate,
        end: endDate,
        className: `__hl_row_type_${workPackage.type.getId()}`,
        workPackage: workPackage,
        type_event: "workpackage"
      };
    });

    // Instead of using two way bindings we manually trigger
    // event rendering here. For whatever reasons, when embedded
    // in a grid, having two way binding will lead to having constantly
    // removed the events after showing them initially.
    // It appears as if the two way binding is initialized twice if used.
    this.ucCalendar.renderEvents(events);
  }

  private warnOnTooManyResults(collection:WorkPackageCollectionResource) {
    if (collection.count < collection.total) {
      const message = this.i18n.t('js.calendar.too_many',
                                  { count: collection.total,
                                               max: WorkPackagesCalendarController.MAX_DISPLAYED });
      this.notificationsService.addNotice(message);
    }
  }

  private setCalendarOptions() {
    if (this.static) {
      this.calendarOptions = this.staticOptions;
    } else {
      this.calendarOptions = this.dynamicOptions;
    }
  }

  private get dynamicOptions() {
  //  let me: WorkPackagesCalendarController;
//    me = this;

    return {
      //editable: false,
      eventLimit: false,
      selectable: true,
      //locale: this.i18n.locale,
      locale: 'ru',
      height: () => {
        // -12 for the bottom padding
        return jQuery(window).height()! - this.calendarElement.offset()!.top - 12;
      },

      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month247, workMonth, week247, workWeek, agendaDayFull, setPeriodButton, addUserTask'
      },
      views: {
        month247: {
          type: 'month',
          buttonText: 'Месяц 24/7'
        },
        workMonth: {
          type: 'month',
          weekends: false,
          buttonText: 'Месяц 24/5'
        },
        week247:{
          type: 'basicWeek',
          buttonText: 'Неделя'
        },
        workWeek:{
          type: 'basicWeek',
          weekends: false,
          buttonText: 'Рабочая неделя'
        },
        agendaDayFull:{
          type: 'agendaDay',
          buttonText: 'День'
        },
        day: {
          titleFormat: 'YYYY, MM, DD'
        },
        customView: {
          type: 'basicWeek',
          duration: { days: 40 }
        }

      },
      customButtons: {
        setPeriodButton: {
          text: 'Задать период',
          click:this.addUserTask.bind(this)
        },
        addUserTask: {
          text: 'Добавить...',
          click: this.addUserTask
         }
      }
    };

  }

  private addUserTask(){
    this.openDialog();
  }

  private get staticOptions() {
    return {
      editable: false,
      eventLimit: false,
      locale: this.i18n.locale,
      height: () => {
        let heightElement = jQuery(this.element.nativeElement);

        while (!heightElement.height() && heightElement.parent()) {
          heightElement = heightElement.parent();
        }

        let topOfCalendar = jQuery(this.element.nativeElement).position().top;
        let topOfHeightElement = heightElement.position().top;

        return heightElement.height()! - (topOfCalendar - topOfHeightElement);
      },
      header: false,
      defaultView: 'basicWeek'
    };
  }

  private defaultQueryProps(startDate:string, endDate:string) {
    let props = { "c": ["id"],
                  "t":
                  "id:asc",
                  "f": [{ "n": "status", "o": "o", "v": [] },
                    //zbd(
                        { "n": "assignee", "o": "=", "v": ["me"] },
                    //)
                        { "n": "datesInterval", "o": "<>d", "v": [startDate, endDate] }],
                  "pp": WorkPackagesCalendarController.MAX_DISPLAYED };

    return JSON.stringify(props);
  }

  private eventDate(workPackage:WorkPackageResource, type:'start'|'due') {
    if (workPackage.isMilestone) {
      return workPackage.date;
    } else {
      return workPackage[`${type}Date`];
    }
  }

  private contentStringMeeting(meeting:any) {
    return `
        <b> Совещание: </b> ${this.sanitizer.sanitize(SecurityContext.HTML, meeting.title)}
        
        <ul class="tooltip--map">
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">Повестка:</span>
            <span class="tooltip--map--value">${this.sanitizer.sanitize(SecurityContext.HTML, meeting.agendaText)}</span>
          </li>
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">${this.i18n.t('js.work_packages.properties.startDate')}:</span>
            <span class="tooltip--map--value">${this.sanitizer.sanitize(SecurityContext.HTML, meeting.startTime)}</span>
          </li>          
          ${meeting.location ?
            `<li class="tooltip--map--item">
              <span class="tooltip--map--key">Местоположение:</span>
              <span class="tooltip--map--value">${this.sanitizer.sanitize(SecurityContext.HTML, meeting.location)}</span>
            </li>` : ''}
          ${meeting.participantList ?
            `<li class="tooltip--map--item">
              <span class="tooltip--map--key">Участники и приглашенные:</span>
              <span class="tooltip--map--value">${this.sanitizer.sanitize(SecurityContext.HTML, meeting.participantList)}</span>
            </li>` : ''}          
        </ul>
        `;
  }

  private contentStringUserTask(userTask:any) {
    if (userTask.kind == "Note") {
      return `
        <b> Заметка: </b> ${this.sanitizer.sanitize(SecurityContext.HTML, userTask.text)}
            `;
    }else{

      let kind = userTask.kind;
      switch (userTask.kind) {
        case 'Task':
          kind = "Задача";
          break;
        case 'Request':
          kind = "Запрос";
          break;
        case 'Note':
          kind = "Заметка";
          break;
        case 'Response':
          kind = "Ответ";
          break;
      }

      return `
        <b> ${kind}: </b> ${this.sanitizer.sanitize(SecurityContext.HTML, userTask.text)} 

         <ul class="tooltip--map">  
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">Назначена:</span>
            <span class="tooltip--map--value">${this.sanitizer.sanitize(SecurityContext.HTML, userTask.assigned_to)}</span>
          </li>          
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">Срок:</span>
            <span class="tooltip--map--value">${this.sanitizer.sanitize(SecurityContext.HTML, userTask.due_date)}</span>
          </li>                   
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">Отметка о выполнении:</span>
            <span class="tooltip--map--value">${this.sanitizer.sanitize(SecurityContext.HTML, userTask.completed)}</span>
          </li>          
        </ul>
            `;
    }
  }

  private contentString(workPackage:WorkPackageResource) {
    this.workPackageGlobal = workPackage;
    return `
        ${this.sanitizedValue(workPackage, 'type')} #${workPackage.id}: ${this.sanitizedValue(workPackage, 'subject', null)}
        <ul class="tooltip--map">
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">${this.i18n.t('js.work_packages.properties.projectName')}:</span>
            <span class="tooltip--map--value">${this.sanitizedValue(workPackage, 'project')}</span>
          </li>
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">${this.i18n.t('js.work_packages.properties.status')}:</span>
            <span class="tooltip--map--value">${this.sanitizedValue(workPackage, 'status')}</span>
          </li>
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">${this.i18n.t('js.work_packages.properties.startDate')}:</span>
            <span class="tooltip--map--value">${this.eventDate(workPackage, 'start')}</span>
          </li>
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">${this.i18n.t('js.work_packages.properties.dueDate')}:</span>
            <span class="tooltip--map--value">${this.eventDate(workPackage, 'due')}</span>
          </li>
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">${this.i18n.t('js.work_packages.properties.assignee')}:</span>
            <span class="tooltip--map--value">${this.sanitizedValue(workPackage, 'assignee')}</span>
          </li>
          <li class="tooltip--map--item">
            <span class="tooltip--map--key">${this.i18n.t('js.work_packages.properties.priority')}:</span>
            <span class="tooltip--map--value">${this.sanitizedValue(workPackage, 'priority')}</span>
          </li>
        </ul>
        `;
  }

  private sanitizedValue(workPackage:WorkPackageResource, attribute:string, toStringMethod:string|null = 'name') {
    let value = workPackage[attribute];
    value = toStringMethod && value ? value[toStringMethod] : value;
    value = value || this.i18n.t('js.placeholders.default');

    return this.sanitizer.sanitize(SecurityContext.HTML, value);
  }

  private removeTooltip(target:ElementRef) {
    // deactivate tooltip so that it is not displayed on the wp show page
    jQuery(target).tooltip({
      disabled: true
    });
  }
}
