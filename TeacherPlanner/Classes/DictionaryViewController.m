//
//  DictionaryViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 16.08.15.
//
//

#import "DictionaryViewController.h"
#import "AnnotationHandler.h"
#import "Word.h"

@interface DictionaryViewController ()

@end

@implementation DictionaryViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.name = NSLocalizedString(@"Word Collection", @"");
        self.title = self.name;
        self.entity = nil;
        self.editable = YES;
        self.addable = YES;
        self.definition = [@{
                            @"context" : @"",
                            @"placeholder" : NSLocalizedString(@"New Word", @""),
                            @"group" : @(YES),
                            @"search" : @(YES),
                            @"delete" : @(YES),
                            @"index" : @(YES),
                            @"bindings" : @[ @{ @"property" : @"name" } ] } mutableCopy];
    }
    return self;
}
                       
- (void)setDataSource:(JSONEntity<AnnotationDataSource> *)dataSource {
    _dataSource = dataSource;
    [(NSMutableDictionary *)self.definition setValue:[dataSource dictionaryAggregation] forKey:@"context"];
    self.entity = [dataSource dictionaryEntity];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Word *word = (Word *)[self aggregationEntityByIndexPath:indexPath];
    if (word) {
        [self.dictionaryDelegate didSelectWord:word.name];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end