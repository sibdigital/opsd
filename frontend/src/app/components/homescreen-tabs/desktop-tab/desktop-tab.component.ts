import {Component, OnInit, QueryList, ViewChild, ViewChildren} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {HomescreenDiagramComponent} from "core-components/homescreen-diagram/homescreen-diagram.component";

export interface ValueOption {
  name:string;
  $href:string | null;
}

@Component({
  selector: 'desktop-tab',
  templateUrl: './desktop-tab.html',
  styleUrls: ['./desktop-tab.sass']
})
export class DesktopTabComponent implements OnInit {
  protected readonly appBasePath:string;
  public upcomingTasksData:any[];
  public dueMilestoneData:any[];
  public problemData:any[];
  public budgetData:any[];

  public loadingProblems:boolean = false;
  public loadingBudgets:boolean = false;
  public loadingUpcomingTasks:boolean = false;
  public loadingDueMilestones:boolean = false;

  public problemCount:number;
  public budgetCount:number;
  public upcomingTasksCount:number;
  public dueMilestoneCount:number;

  private pageSize = 5;

  public problemPages:number = 0;
  public budgetPages:number = 0;
  public upcomingTasksPages:number = 0;
  public dueMilestonePages:number = 0;

  public problemPage:number = 1;
  public budgetPage:number = 1;
  public upcomingTasksPage:number = 1;
  public dueMilestonePage:number = 1;

  public problemVisibility:boolean = false;
  public budgetVisibility:boolean = false;
  public upcomingTasksVisibility:boolean = false;
  public dueMilestoneVisibility:boolean = false;

  public options:any[];
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  public compareByHref = AngularTrackingHelpers.compareByHref;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
  @ViewChildren(HomescreenDiagramComponent) homescreenDiagrams:QueryList<HomescreenDiagramComponent>;

  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects_for_user.toString())
      .toPromise()
      .then((projects:CollectionResource<HalResource>) => {
        this.valueOptions = projects.elements.sort((a, b) => (a.name > b.name ? 1 : -1)).map((el:HalResource) => {
          return {name: el.name, $href: el.id};
        });
        this.valueOptions.unshift({name: 'Все проекты', $href: "0"});
        this.value = this.valueOptions[0];
        this.getUpcomingAndDue();
        this.getProblems();
        this.getBudgets();
      });
  }

  public getUpcomingAndDue() {
    this.loadingUpcomingTasks = true;
    this.upcomingTasksCount = 0;
    this.upcomingTasksData = [];
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_future.toString(),
        {pageSize: this.pageSize, offset: this.upcomingTasksPage, project: this.selectedOption ? this.selectedOption.$href !== "0" ? String(this.selectedOption.$href) : "0" : "0"})
      .toPromise()
      .then((resources:CollectionResource<WorkPackageResource>) => {
        let total:number = resources.total;
        let pageSize:number = resources.pageSize;
        let remainder = total % pageSize;
        this.upcomingTasksPages = (total - remainder) / pageSize;
        if (remainder !== 0) {
          this.upcomingTasksPages++;
        }
        let beginNumber = (this.upcomingTasksPage - 1) * this.pageSize + 1;
        resources.elements.map( (el, i) => {
          let id = el.id;
          let subject = el.subject;
          let projectId = '';
          let project = '';
          if (el.$links.project) {
            projectId = el.$links.project.href.substr(17);
            project = el.$links.project.title;
          }
          let upcoming_tasks = {id: id, subject: subject, project: project, projectId: projectId, number: beginNumber + i};
          this.upcomingTasksData[i] = upcoming_tasks;
        });
        this.upcomingTasksCount = resources.elements ? resources.elements.length : 0;
        this.loadingUpcomingTasks = false;
        this.getDueMilestones();
      });
  }

  public getUpcomingTasks() {
    this.loadingUpcomingTasks = true;
    this.upcomingTasksCount = 0;
    this.upcomingTasksData = [];
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_future.toString(),
        {pageSize: this.pageSize, offset: this.upcomingTasksPage, project: this.selectedOption ? this.selectedOption.$href !== "0" ? String(this.selectedOption.$href) : "0" : "0"})
      .toPromise()
      .then((resources:CollectionResource<WorkPackageResource>) => {
        let total:number = resources.total;
        let pageSize:number = resources.pageSize;
        let remainder = total % pageSize;
        this.upcomingTasksPages = (total - remainder) / pageSize;
        if (remainder !== 0) {
          this.upcomingTasksPages++;
        }
        let beginNumber = (this.upcomingTasksPage - 1) * this.pageSize + 1;
        resources.elements.map( (el, i) => {
          let id = el.id;
          let subject = el.subject;
          let projectId = '';
          let project = '';
          if (el.$links.project) {
            projectId = el.$links.project.href.substr(17);
            project = el.$links.project.title;
          }
          let upcoming_tasks = {id: id, subject: subject, project: project, projectId: projectId, number: beginNumber + i};
          this.upcomingTasksData[i] = upcoming_tasks;
        });
        this.upcomingTasksCount = resources.elements ? resources.elements.length : 0;
        this.loadingUpcomingTasks = false;
      });
  }

  public loadUpcomingTasksByPage(i:number) {
    if (this.upcomingTasksPage !== i) {
      this.upcomingTasksPage = i;
      this.getUpcomingTasks();
    }
  }

  public changeUpcomingTasksVisibility() {
    if (this.upcomingTasksVisibility) {
      this.upcomingTasksVisibility = false;
    } else {
      this.upcomingTasksVisibility = true;
    }
  }

  public getDueMilestones() {
    this.loadingDueMilestones = true;
    this.dueMilestoneCount = 0;
    this.dueMilestoneData = [];
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_due.toString(),
        {pageSize: this.pageSize, offset: this.dueMilestonePage, project: this.selectedOption ? this.selectedOption.$href !== "0" ? String(this.selectedOption.$href) : "0" : "0"})
      .toPromise()
      .then((resources:CollectionResource<WorkPackageResource>) => {
        let total:number = resources.total;
        let pageSize:number = resources.pageSize;
        let remainder = total % pageSize;
        this.dueMilestonePages = (total - remainder) / pageSize;
        if (remainder !== 0) {
          this.dueMilestonePages++;
        }
        let beginNumber = (this.dueMilestonePage - 1) * this.pageSize + 1;
        resources.elements.map( (el, i) => {
          let id = el.id;
          let subject = el.subject;
          let projectId = '';
          let project = '';
          if (el.$links.project) {
            projectId = el.$links.project.href.substr(17);
            project = el.$links.project.title;
          }
          let due_milestone = {id: id, subject: subject, project: project, projectId: projectId, number: beginNumber + i};
          this.dueMilestoneData[i] = due_milestone;
        });
        this.dueMilestoneCount = resources.elements ? resources.elements.length : 0;
        this.loadingDueMilestones = false;
      });
  }

  public loadDueMilestonesByPage(i:number) {
    if (this.dueMilestonePage !== i) {
      this.dueMilestonePage = i;
      this.getDueMilestones();
    }
  }

  public changeDueMilestoneVisibility() {
    if (this.dueMilestoneVisibility) {
      this.dueMilestoneVisibility = false;
    } else {
      this.dueMilestoneVisibility = true;
    }
  }

  public getProblems() {
    this.loadingProblems = true;
    this.problemCount = 0;
    this.problemData = [];
    let params;
    if (this.selectedOption && this.selectedOption.$href !== "0") {
      params = {"status": "created", "project": this.selectedOption.$href, pageSize: 5, offset: this.problemPage};
    } else {
      params = {"status": "created", pageSize: this.pageSize, offset: this.problemPage};
    }
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(), params)
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        let total:number = resources.total;
        let pageSize:number = resources.pageSize;
        let remainder = total % pageSize;
        this.problemPages = (total - remainder) / pageSize;
        if (remainder !== 0) {
          this.problemPages++;
        }
        let beginNumber = (this.problemPage - 1) * this.pageSize + 1;
        resources.elements.map( (el, i) => {
          let id = el.id;
          let risk = el.risk;
          let wptitle = el.workPackage ? el.workPackage.$links.self.title : '';
          let wpid = el.workPackage ? el.workPackage.$links.self.href.slice(22) : '';
          let problems = {id: id, risk: risk, wptitle: wptitle, wpid: wpid, number: beginNumber + i};
          this.problemData[i] = problems;
        });
        this.problemCount = resources.elements ? resources.elements.length : 0;
        this.loadingProblems = false;
      });
  }

  public loadProblemsByPage(i:number) {
    if (this.problemPage !== i) {
      this.problemPage = i;
      this.getProblems();
    }
  }

  public changeProblemVisibility() {
    if (this.problemVisibility) {
      this.problemVisibility = false;
    } else {
      this.problemVisibility = true;
    }
  }

  public getBudgets() {
    this.loadingBudgets = true;
    this.budgetCount = 0;
    this.budgetData = [];
    let params;
    if (this.selectedOption && this.selectedOption.$href !== "0") {
      params = {"project": this.selectedOption.$href};
    } else {
      params = {pageSize: this.pageSize, offset: (this.budgetPage - 1) * this.pageSize};
    }
    this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.summary_budgets.toString(), params)
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        let total:number = resources.total;
        let pageSize:number = resources.pageSize;
        let remainder = total % pageSize;
        this.budgetPages = (total - remainder) / pageSize;
        if (remainder !== 0) {
          this.budgetPages++;
        }
        let beginNumber = (this.budgetPage - 1) * this.pageSize + 1;
        resources.elements.map((el, i) => {
          let id = el.project.id;
          let name = el.project.name;
          let spent = el.spent;
          let total_budget = el.total_budget;
          // let budget = {id: id, name: name, value: total_budget === '0.0' ? 0 : total_budget - spent };
          let budget = {id: id, name: name, value: total_budget === '0.0' ? 0 : spent / total_budget, number: beginNumber + i};
          this.budgetData[i] = budget;
        });
        this.budgetCount = resources.elements ? resources.elements.length : 0;
        this.loadingBudgets = false;
      });
  }

  public loadBudgetsByPage(i:number) {
    if (this.budgetPage !== i) {
      this.budgetPage = i;
      this.getBudgets();
    }
  }

  public changeBudgetVisibility() {
    if (this.budgetVisibility) {
      this.budgetVisibility = false;
    } else {
      this.budgetVisibility = true;
    }
  }

  public get selectedOption() {
    const $href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === $href)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.$href === val.$href);
    this.value = option;
  }

  public handleUserSubmit() {
    if (this.selectedOption) {
      this.homescreenDiagrams.forEach((diagram) => {
        if (this.selectedOption.$href) {
          diagram.refresh(this.selectedOption.$href);
        }
      });
      this.blueChild.changeFilter(String(this.selectedOption.$href));
      this.upcomingTasksPage = 1;
      this.upcomingTasksPages = 0;
      this.upcomingTasksVisibility = false;
      this.getUpcomingTasks();
      this.dueMilestonePage = 1;
      this.dueMilestonePages = 0;
      this.dueMilestoneVisibility = false;
      this.getDueMilestones();
      this.problemPage = 1;
      this.problemPages = 0;
      this.problemVisibility = false;
      this.getProblems();
      this.budgetPage = 1;
      this.budgetPages = 0;
      this.budgetVisibility = false;
      this.getBudgets();
    }
  }

  public getGreenClass(i:number):string {
    if (i % 2 === 0) {
      return "colored-col-bright-green";
    } else {
      return "colored-col-green";
    }
  }

  public getRedClass(i:number):string {
    if (i % 2 === 0) {
      return "colored-col-bright-red";
    } else {
      return "colored-col-red";
    }
  }

  public getOrangeClass(i:number):string {
    if (i % 2 === 0) {
      return "colored-col-bright-orange";
    } else {
      return "colored-col-orange";
    }
  }

  public getPurpleClass(i:number):string {
    if (i % 2 === 0) {
      return "colored-col-bright-purple";
    } else {
      return "colored-col-purple";
    }
  }

  public getBasePath():string {
    return this.appBasePath;
  }

  public shorten(input:string):string {
    if (input) {
      return input.length > 70 ? input.slice(0, 70) + '...' : input;
    } else {
      return '';
    }
  }
}
