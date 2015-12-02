require 'date'

class NibFree::Generator
  def initialize(basename)
    raise "Basename cannot be blank" if basename.nil? || basename.empty?
    @basename = basename

    @controller_class_name = basename + "Controller"
    @view_class_name = basename + "View"

    view_prefix_start = (basename =~ /[A-Z][a-z]+$/)
    raise "Basename does not contain a view prefix" unless view_prefix_start
    @view_property_name = basename[view_prefix_start..-1].downcase + 'View'
  end

  def header(filename)
    <<OBJC
//
// #{filename}.h
// 
// Created on #{Date.today} using NibFree
// 
OBJC
  end

  def write_file(filename, code)
    File.open filename, 'w' do |f|
      f.write header(filename)
      f.write code
    end
  end

  def emit_files
    write_file @controller_class_name + '.h', <<OBJC

#import <UIKit/UIKit.h>

@protocol #{@controller_class_name}Delegate;

@interface #{@controller_class_name} : UIViewController

@property (nonatomic, weak) id<#{@controller_class_name}Delegate> delegate;

@end

@protocol #{@controller_class_name}Delegate <NSObject>

@end

OBJC

    write_file @controller_class_name + '.m', <<OBJC

#import "#{@controller_class_name}.h"
#import "#{@view_class_name}.h"

@interface #{@controller_class_name} () <#{@view_class_name}Delegate>

@property (nonatomic, strong, readonly) #{@view_class_name} *#{@view_property_name};

@end

@implementation #{@controller_class_name}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // custom initialisation
    }
    return self;
}

- (#{@view_class_name} *)#{@view_property_name}
{
    return (#{@view_class_name} *)self.view;
}

- (void)loadView
{
    self.view = [[#{@view_class_name}  alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.#{@view_property_name}.delegate = self;
}

@end

OBJC
    
    write_file @view_class_name + '.h', <<OBJC

#import <UIKit/UIKit.h>

@protocol #{@view_class_name}Delegate;

@interface #{@view_class_name} : UIView

@property (nonatomic, weak) id<#{@view_class_name}Delegate> delegate;

@end

@protocol #{@view_class_name}Delegate <NSObject>

@end

OBJC
    
    write_file @view_class_name + '.m', <<OBJC

#import "#{@view_class_name}.h"

@interface #{@view_class_name} ()

@end

@implementation #{@view_class_name}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.opaque = YES;

        // custom initialisation
    }
    return self;
}

@end

OBJC

  end
end
