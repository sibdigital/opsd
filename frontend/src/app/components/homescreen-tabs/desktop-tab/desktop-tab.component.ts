import {Component, OnInit, QueryList, ViewChild, ViewChildren} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {HomescreenDiagramComponent} from "core-components/homescreen-diagram/homescreen-diagram.component";
import {DiagramHomescreenResource} from "core-app/modules/hal/resources/diagram-homescreen-resource";

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

  public targetChartData:any[];
  public targetChartLabel:string;
  public targetChartLoading:boolean = false;
  public KTChartData:any[];
  public KTChartLabel:string;
  public KTChartLoading:boolean = false;
  public budgetChartData:any[];
  public budgetChartLabel:string;
  public budgetChartLoading:boolean = false;
  public risksAndProblemsChartData:any[];
  public risksAndProblemsChartLabel:string;
  public risksAndProblemsChartLoading:boolean = false;

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

  keyword = 'name';
  data_autocomplete:any[] = [];
  data_choosed:any;

  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  public compareByHref = AngularTrackingHelpers.compareByHref;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
  @ViewChildren(HomescreenDiagramComponent) homescreenDiagrams:QueryList<HomescreenDiagramComponent>;
  @ViewChild('autocomplete') auto:any;

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
          this.data_autocomplete.push({id: el.id, name: el.name});
          return {name: el.name, $href: el.id};
        });
        this.data_choosed = {name: 'Все проекты', id: "0"};
        this.value = this.valueOptions[0];

        this.getTargetIndicatorsChart();
        this.getKTChart();
        this.getBudgetChart();
        this.getRisksAndProblemsChart();
        this.getProblems();
        this.getBudgets();
        this.getDueMilestones();
        this.getUpcomingTasks();
      }).catch(function (reason) {
      console.log(reason);
    });
  }

  public getUpcomingTasks() {
    this.loadingUpcomingTasks = true;
    this.upcomingTasksCount = 0;
    this.upcomingTasksData = [];
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_future.toString(),
        {pageSize: this.pageSize, offset: this.upcomingTasksPage, project: String(this.data_choosed.id)})
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
      }).catch(function (reason) {
      console.log(reason);
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
        {pageSize: this.pageSize, offset: this.dueMilestonePage, project: this.data_choosed.id})
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
      }).catch(function (reason) {
      console.log(reason);
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
    if (this.data_choosed.id !== "0") {
      params = {"status": "created", "project": this.data_choosed.id, pageSize: 5, offset: this.problemPage};
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
      }).catch(function (reason) {
      console.log(reason);
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
    if (this.data_choosed.id !== "0") {
      params = {"project": this.data_choosed.id, offset: (this.budgetPage - 1) * this.pageSize};
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
      }).catch(function (reason) {
      console.log(reason);
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

  public getTargetIndicatorsChart() {
    this.targetChartLoading = true;
    this.halResourceService
      .get<DiagramHomescreenResource>(`${this.pathHelper.api.v3.diagrams.toString()}/pokazateli?project=${String(this.data_choosed.id)}`)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.targetChartData = resource.data;
        this.targetChartLabel = resource.label;
        this.targetChartLoading = false;
      }).catch(function (reason) {
      console.log(reason);
    });
  }

  public getKTChart() {
    this.KTChartLoading = true;
    this.halResourceService
      .get<DiagramHomescreenResource>(`${this.pathHelper.api.v3.diagrams.toString()}/kt?project=${String(this.data_choosed.id)}`)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.KTChartData = resource.data;
        this.KTChartLabel = resource.label;
        this.KTChartLoading = false;
      }).catch(function (reason) {
      console.log(reason);
    });
  }

  public getBudgetChart() {
    this.budgetChartLoading = true;
    this.halResourceService
      .get<DiagramHomescreenResource>(`${this.pathHelper.api.v3.diagrams.toString()}/budget?project=${String(this.data_choosed.id)}`)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.budgetChartData = resource.data;
        this.budgetChartLabel = resource.label;
        this.budgetChartLoading = false;
      }).catch(function (reason) {
      console.log(reason);
    });
  }

  public getRisksAndProblemsChart() {
    this.risksAndProblemsChartLoading = true;
    this.halResourceService
      .get<DiagramHomescreenResource>(`${this.pathHelper.api.v3.diagrams.toString()}/riski?project=${String(this.data_choosed.id)}`)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.risksAndProblemsChartData = resource.data;
        this.risksAndProblemsChartLabel = resource.label;
        this.risksAndProblemsChartLoading = false;
      }).catch(function (reason) {
      console.log(reason);
    });
  }

  public check_load() {
    return this.targetChartLoading || this.KTChartLoading || this.budgetChartLoading || this.risksAndProblemsChartLoading ||
      this.loadingUpcomingTasks || this.loadingDueMilestones || this.loadingProblems || this.loadingBudgets;
  }

  selectEvent(item:any) {
    this.auto.close();
    this.data_choosed = item;
    this.getTargetIndicatorsChart();
    this.getKTChart();
    this.getBudgetChart();
    this.getRisksAndProblemsChart();
    this.blueChild.changeFilter(String(this.data_choosed.id));
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
