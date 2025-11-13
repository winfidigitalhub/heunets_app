import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/bottom_nav_bar.dart';
import '../bloc/saved_jobs_bloc.dart';
import '../bloc/saved_jobs_event.dart';
import '../bloc/saved_jobs_state.dart';
import '../../../jobs/data/model/job_model.dart';
import '../../../jobs/presentation/widget/jobs_widgets.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved jobs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SavedJobsBloc>().add(const LoadSavedJobsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Job'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: BlocBuilder<SavedJobsBloc, SavedJobsState>(
        builder: (context, state) {
          if (state is SavedJobsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade900,
              ),
            );
          } else if (state is SavedJobsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is SavedJobsEmpty) {
            return const Center(child: Text('You have no saved jobs'));
          } else if (state is SavedJobsLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.jobs.length,
              itemBuilder: (context, index) {
                Job job = state.jobs[index];
                return JobCard(job: job);
              },
            );
          }
          return const Center(child: Text('You have no saved jobs'));
        },
      ),
      bottomNavigationBar: const GlobalBottomNavBar(),
    );
  }
}

