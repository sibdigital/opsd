import {Component, Input, OnDestroy} from '@angular/core';
import {Transition} from '@uirouter/core';
import {WorkPackageCacheService} from 'core-components/work-packages/work-package-cache.service';
import {WorkPackageResource} from 'core-app/modules/hal/resources/work-package-resource';
import {componentDestroyed} from 'ng2-rx-componentdestroyed';
import {takeUntil} from 'rxjs/operators';
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';

@Component({
  selector: 'wp-targets-tab',
  templateUrl: './targets-tab.html'

})
export class WorkPackageTargetsTabComponent implements OnDestroy {
  @Input() public workPackageId?:string;
  public workPackage:WorkPackageResource;

  public constructor(readonly I18n:I18nService,
                     readonly $transition:Transition,
                     readonly wpCacheService:WorkPackageCacheService) {
  }

  ngOnInit() {
    const wpId = this.workPackageId || this.$transition.params('to').workPackageId;
    this.wpCacheService.loadWorkPackage(wpId)
      .values$()
      .pipe(
        takeUntil(componentDestroyed(this))
      )
      .subscribe((wp) => {
        this.workPackageId = wp.id;
        this.workPackage = wp;
      });
  }

  ngOnDestroy() {
    // Nothing to do
  }
}
