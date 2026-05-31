<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Amenity;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void {
        foreach(['customer','owner','admin'] as $role)
            Role::firstOrCreate(['name'=>$role,'guard_name'=>'web']);

        $admin = User::firstOrCreate(['email'=>'admin@hajez.com'],['name'=>'Admin','phone'=>'0700000000','password'=>Hash::make('Admin123')]);
        $admin->assignRole('admin');

        $amenities = [
            ['name'=>'مسبح','icon'=>'pool','category'=>'entertainment'],
            ['name'=>'مسبح مغطى','icon'=>'pool','category'=>'entertainment'],
            ['name'=>'باربيكيو','icon'=>'outdoor_grill','category'=>'entertainment'],
            ['name'=>'ملعب أطفال','icon'=>'child_care','category'=>'entertainment'],
            ['name'=>'ملعب كرة قدم','icon'=>'sports_soccer','category'=>'sports'],
            ['name'=>'تنس طاولة','icon'=>'sports','category'=>'sports'],
            ['name'=>'بلياردو','icon'=>'sports','category'=>'entertainment'],
            ['name'=>'واي فاي','icon'=>'wifi','category'=>'facilities'],
            ['name'=>'تكييف','icon'=>'ac_unit','category'=>'facilities'],
            ['name'=>'مطبخ مجهز','icon'=>'kitchen','category'=>'facilities'],
            ['name'=>'غرف نوم','icon'=>'bed','category'=>'facilities'],
            ['name'=>'حارس أمن','icon'=>'security','category'=>'security'],
            ['name'=>'كاميرات مراقبة','icon'=>'videocam','category'=>'security'],
            ['name'=>'موقف سيارات','icon'=>'local_parking','category'=>'facilities'],
            ['name'=>'سينما خارجية','icon'=>'movie','category'=>'entertainment'],
            ['name'=>'جلسات خارجية','icon'=>'chair','category'=>'facilities'],
        ];
        foreach($amenities as $a) Amenity::firstOrCreate(['name'=>$a['name']],$a);
    }
}
