// -----------------------------------------------------------------------------
// Copyright 2011 Patrick Näf (herzbube@herzbube.ch)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------


// Project includes
#import "ViewGameController.h"
#import "ArchiveGame.h"
#import "../ui/TableViewCellFactory.h"
#import "../command/RenameGameCommand.h"


// -----------------------------------------------------------------------------
/// @brief Enumerates the sections presented in the "Edit Player" table view.
// -----------------------------------------------------------------------------
enum EditGameTableViewSection
{
  FileNameSection,
  FileAttributesSection,
  MaxSection
};

// -----------------------------------------------------------------------------
/// @brief Enumerates items in the FileNameSection.
// -----------------------------------------------------------------------------
enum FileNameSectionItem
{
  FileNameItem,
  MaxFileNameSectionItem
};

// -----------------------------------------------------------------------------
/// @brief Enumerates items in the FileAttributesSection.
// -----------------------------------------------------------------------------
enum FileAttributesSectionItem
{
  FileDateItem,
  FileSizeItem,
  MaxFileAttributesSectionItem,
};

// -----------------------------------------------------------------------------
/// @brief Class extension with private methods for ViewGameController.
// -----------------------------------------------------------------------------
@interface ViewGameController()
/// @name Initialization and deallocation
//@{
- (void) dealloc;
//@}
/// @name UIViewController methods
//@{
- (void) viewDidLoad;
- (void) viewDidUnload;
//@}
/// @name UITableViewDataSource protocol
//@{
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView;
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
//@}
/// @name UITableViewDelegate protocol
//@{
- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
//@}
/// @name EditTextDelegate protocol
//@{
- (void) didEndEditing:(EditTextController*)editTextController didCancel:(bool)didCancel;
//@}
/// @name Helpers
//@{
- (void) editGame;
//@}
@end


@implementation ViewGameController

@synthesize game;


// -----------------------------------------------------------------------------
/// @brief Convenience constructor. Creates a ViewGameController instance of
/// grouped style that is used to view information associated with @a game.
// -----------------------------------------------------------------------------
+ (ViewGameController*) controllerWithGame:(ArchiveGame*)game
{
  ViewGameController* controller = [[ViewGameController alloc] initWithStyle:UITableViewStyleGrouped];
  if (controller)
  {
    [controller autorelease];
    controller.game = game;
  }
  return controller;
}

// -----------------------------------------------------------------------------
/// @brief Deallocates memory allocated by this ViewGameController object.
// -----------------------------------------------------------------------------
- (void) dealloc
{
  self.game = nil;
  [super dealloc];
}

// -----------------------------------------------------------------------------
/// @brief Called after the controller’s view is loaded into memory, usually
/// to perform additional initialization steps.
// -----------------------------------------------------------------------------
- (void) viewDidLoad
{
  [super viewDidLoad];

  self.navigationItem.title = @"View Game";
}

// -----------------------------------------------------------------------------
/// @brief Called when the controller’s view is released from memory, e.g.
/// during low-memory conditions.
///
/// Releases additional objects (e.g. by resetting references to retained
/// objects) that can be easily recreated when viewDidLoad() is invoked again
/// later.
// -----------------------------------------------------------------------------
- (void) viewDidUnload
{
  [super viewDidUnload];
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDataSource protocol method.
// -----------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
  return MaxSection;
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDataSource protocol method.
// -----------------------------------------------------------------------------
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case FileNameSection:
      return MaxFileNameSectionItem;
    case FileAttributesSection:
      return MaxFileAttributesSectionItem;
    default:
      assert(0);
      break;
  }
  return 0;
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDataSource protocol method.
// -----------------------------------------------------------------------------
- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  UITableViewCell* cell = [TableViewCellFactory cellWithType:Value1CellType tableView:tableView];
  switch (indexPath.section)
  {
    case FileNameSection:
    {
      switch (indexPath.row)
      {
        case FileNameItem:
        {
          cell.textLabel.text = @"File name";
          cell.detailTextLabel.text = self.game.fileName;
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          break;
        }
        default:
          assert(0);
          break;
      }
      break;
    }
    case FileAttributesSection:
    {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      switch (indexPath.row)
      {
        case FileDateItem:
          cell.textLabel.text = @"Last saved";
          cell.detailTextLabel.text = self.game.fileDate;
          break;
        case FileSizeItem:
          cell.textLabel.text = @"File size (in KB)";
          cell.detailTextLabel.text = self.game.fileSize;
          break;
        default:
          assert(0);
          break;
      }
      break;
    }
    default:
      assert(0);
      break;
  }

  return cell;
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDelegate protocol method.
// -----------------------------------------------------------------------------
- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:NO];

  switch (indexPath.section)
  {
    case FileNameSection:
    {
      switch (indexPath.row)
      {
        case FileNameItem:
          [self editGame];
          break;
        default:
          break;
      }
      break;
    }
    default:
      break;
  }
}

// -----------------------------------------------------------------------------
/// @brief Displays EditTextController to allow the user to change the
/// archive game's file name.
// -----------------------------------------------------------------------------
- (void) editGame
{
  EditTextController* editTextController = [[EditTextController controllerWithText:self.game.fileName title:@"File name" delegate:self] retain];
  UINavigationController* navigationController = [[UINavigationController alloc]
                                                  initWithRootViewController:editTextController];
  navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  [self presentModalViewController:navigationController animated:YES];
  [navigationController release];
  [editTextController release];
}

// -----------------------------------------------------------------------------
/// @brief This method is invoked when the user has finished editing the text.
///
/// @a didCancel is true if the user has cancelled editing. @a didCancel is
/// false if the user has confirmed editing.
// -----------------------------------------------------------------------------
- (void) didEndEditing:(EditTextController*)editTextController didCancel:(bool)didCancel;
{
  if (! didCancel)
  {
    RenameGameCommand* command = [[RenameGameCommand alloc] init];
    command.game = self.game;
    command.newFileName = editTextController.text;
    [command submit];

    [self.tableView reloadData];
  }
  [self dismissModalViewControllerAnimated:YES];
}

@end
